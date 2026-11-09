using System.Globalization;
using System.Net;
using System.Net.Sockets;
using System.Text;

namespace Corning.Pos.RfidCapture;

public static class CaptureCli
{
    public const string Usage = "RFID 原始取樣（不解析、不送設備命令、不寫 DB）\n" +
        "  --host <目前設備 IP> --port <1-65535> --seconds <1-300> --output <新 JSONL 檔>\n" +
        "  --replay <JSONL 檔>\n" +
        "  --help\n端點沒有預設值。取樣檔應放在 artifacts/captures 等受控位置。";

    public static async Task<int> RunAsync(string[] args, TextWriter output, CancellationToken stop)
    {
        if (args is ["--help"]) { await output.WriteLineAsync(Usage); return 0; }
        try
        {
            if (args is ["--replay", var replayPath])
            {
                using var reader = File.OpenText(replayPath);
                var result = await RawCapture.ReplayAsync(reader);
                await output.WriteLineAsync($"REPLAY_OK chunks={result.Chunks} bytes={result.Bytes}；未執行卡號解析或記帳。");
                return 0;
            }
            var options = Parse(args);
            if (!options.TryGetValue("--host", out var host) || !IPAddress.TryParse(host, out var address) ||
                !options.TryGetValue("--port", out var portText) || !int.TryParse(portText, CultureInfo.InvariantCulture, out var port) || port is < 1 or > 65535 ||
                !options.TryGetValue("--seconds", out var secondsText) || !int.TryParse(secondsText, CultureInfo.InvariantCulture, out var seconds) || seconds is < 1 or > 300 ||
                !options.TryGetValue("--output", out var path) || string.IsNullOrWhiteSpace(path))
            {
                await output.WriteLineAsync(Usage);
                return 2;
            }
            path = Path.GetFullPath(path);
            Directory.CreateDirectory(Path.GetDirectoryName(path)!);
            // 先確認能保存，再連設備；CreateNew 保護既有取樣不被覆蓋。
            await using var file = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.Read);
            await using var writer = new StreamWriter(file, new UTF8Encoding(false), leaveOpen: true);
            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(stop);
            timeout.CancelAfter(TimeSpan.FromSeconds(seconds));
            using var client = new TcpClient(address.AddressFamily);
            await client.ConnectAsync(address, port, timeout.Token);
            await output.WriteLineAsync("已連線，請刷測試卡；僅接收，不送初始化／ACK／清除命令。");
            var captured = await RawCapture.RecordAsync(client.GetStream(), writer, timeout.Token);
            await writer.FlushAsync();
            file.Flush(flushToDisk: true);
            await output.WriteLineAsync($"CAPTURE chunks={captured.Chunks} bytes={captured.Bytes}");
            if (captured.Chunks == 0)
            {
                await output.WriteLineAsync("沒有收到原始資料；不能視為刷卡測試通過。 ");
                return 1;
            }
            return stop.IsCancellationRequested ? 130 : 0;
        }
        catch (OperationCanceledException)
        {
            await output.WriteLineAsync("連線或操作已取消／逾時，未宣告接收成功。 ");
            return stop.IsCancellationRequested ? 130 : 1;
        }
        catch (Exception failure) when (failure is IOException or SocketException or FormatException or System.Text.Json.JsonException or ArgumentException)
        {
            await output.WriteLineAsync($"操作失敗（{failure.GetType().Name}），請核對端點、路徑、檔案及本機環境。 ");
            return 1;
        }
    }

    private static Dictionary<string, string> Parse(string[] args)
    {
        var result = new Dictionary<string, string>();
        if (args.Length != 8) return result;
        for (var index = 0; index < args.Length; index += 2)
        {
            if (args[index] is not ("--host" or "--port" or "--seconds" or "--output") ||
                !result.TryAdd(args[index], args[index + 1])) return [];
        }
        return result;
    }
}
