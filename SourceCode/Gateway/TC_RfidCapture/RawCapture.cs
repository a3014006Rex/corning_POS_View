using System.Security.Cryptography;
using System.Text.Json;

namespace Corning.Pos.RfidCapture;

public sealed record CaptureChunk(int SchemaVersion, int Sequence, DateTimeOffset ReceivedAt, int ByteCount, string Base64Data, string Sha256);
public sealed record CaptureSummary(int Chunks, long Bytes);

public static class RawCapture
{
    public static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);
    private const long MaxBytes = 16 * 1024 * 1024;

    // 保存 ReadAsync 取得的原始片段；片段不是設備 frame，也不宣稱已解析卡號。
    public static async Task<CaptureSummary> RecordAsync(Stream input, TextWriter output, CancellationToken cancellationToken)
    {
        var buffer = new byte[4096];
        var sequence = 0;
        long bytes = 0;
        while (!cancellationToken.IsCancellationRequested)
        {
            int count;
            try { count = await input.ReadAsync(buffer, cancellationToken); }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested) { break; }
            if (count == 0) break;
            if (bytes + count > MaxBytes) throw new InvalidDataException("取樣達到 16 MiB 上限，請另開取樣檔。 ");
            var chunk = new CaptureChunk(1, ++sequence, DateTimeOffset.UtcNow, count,
                Convert.ToBase64String(buffer, 0, count), Convert.ToHexString(SHA256.HashData(buffer.AsSpan(0, count))));
            await output.WriteLineAsync(JsonSerializer.Serialize(chunk, JsonOptions));
            await output.FlushAsync();
            bytes += count;
        }
        return new CaptureSummary(sequence, bytes);
    }

    public static async Task<CaptureSummary> ReplayAsync(TextReader input, Stream? restoredBytes = null)
    {
        var sequence = 0;
        long bytes = 0;
        while (await input.ReadLineAsync() is { } line)
        {
            if (string.IsNullOrWhiteSpace(line)) continue;
            var chunk = JsonSerializer.Deserialize<CaptureChunk>(line, JsonOptions)
                ?? throw new InvalidDataException("無效取樣紀錄。 ");
            if (chunk.SchemaVersion != 1 || chunk.Sequence != sequence + 1 || chunk.ByteCount is < 1 or > 4096)
                throw new InvalidDataException("取樣版本、序號或長度不正確。 ");
            var data = Convert.FromBase64String(chunk.Base64Data);
            if (data.Length != chunk.ByteCount || bytes + data.Length > MaxBytes ||
                !string.Equals(Convert.ToHexString(SHA256.HashData(data)), chunk.Sha256, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("取樣長度或 SHA-256 不符，請保留原檔供核對。 ");
            if (restoredBytes is not null) await restoredBytes.WriteAsync(data);
            sequence++;
            bytes += data.Length;
        }
        if (sequence == 0) throw new InvalidDataException("沒有可重播的接收片段。 ");
        return new CaptureSummary(sequence, bytes);
    }
}
