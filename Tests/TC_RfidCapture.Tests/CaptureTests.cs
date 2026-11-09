using System.Net;
using System.Net.Sockets;
using System.Text;
using Corning.Pos.RfidCapture;

namespace Corning.Pos.CaptureTests;

public sealed class CaptureTests
{
    [Fact]
    public async Task ReplayRestoresAllBytesRegardlessOfReadBoundaries()
    {
        var original = Enumerable.Range(0, 12000).Select(value => (byte)(value % 251)).ToArray();
        using var source = new MemoryStream(original);
        using var log = new StringWriter();
        var captured = await RawCapture.RecordAsync(source, log, CancellationToken.None);
        using var restored = new MemoryStream();
        var replayed = await RawCapture.ReplayAsync(new StringReader(log.ToString()), restored);
        Assert.Equal(original, restored.ToArray());
        Assert.Equal(captured, replayed);
        Assert.True(replayed.Chunks > 1);
    }

    [Fact]
    public async Task LoopbackTcpCapturePreservesSplitAndCombinedData()
    {
        var data = Encoding.UTF8.GetBytes("SYNTHETIC ONLY: two reads do not mean two RFID frames.");
        var listener = new TcpListener(IPAddress.Loopback, 0);
        listener.Start();
        try
        {
            using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(5));
            var server = Task.Run(async () =>
            {
                using var connection = await listener.AcceptTcpClientAsync(timeout.Token);
                await connection.GetStream().WriteAsync(data.AsMemory(0, 3), timeout.Token);
                await connection.GetStream().WriteAsync(data.AsMemory(3), timeout.Token);
            });
            using var client = new TcpClient();
            await client.ConnectAsync(IPAddress.Loopback, ((IPEndPoint)listener.LocalEndpoint).Port, timeout.Token);
            using var log = new StringWriter();
            await RawCapture.RecordAsync(client.GetStream(), log, timeout.Token);
            using var restored = new MemoryStream();
            await RawCapture.ReplayAsync(new StringReader(log.ToString()), restored);
            await server;
            Assert.Equal(data, restored.ToArray());
        }
        finally { listener.Stop(); }
    }

    [Fact]
    public async Task CorruptHashCannotPassReplay()
    {
        using var log = new StringWriter();
        await RawCapture.RecordAsync(new MemoryStream([1, 2, 3]), log, CancellationToken.None);
        var text = log.ToString();
        var hash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(new byte[] { 1, 2, 3 }));
        await Assert.ThrowsAsync<InvalidDataException>(() => RawCapture.ReplayAsync(new StringReader(text.Replace(hash, new string('0', 64)))));
    }

    [Fact]
    public async Task EmptyReplayFailsInsteadOfReportingSuccess() =>
        await Assert.ThrowsAsync<InvalidDataException>(() => RawCapture.ReplayAsync(new StringReader("")));

    [Fact]
    public async Task CliRequiresExplicitEndpoint()
    {
        using var output = new StringWriter();
        Assert.Equal(2, await CaptureCli.RunAsync([], output, CancellationToken.None));
        Assert.Contains("端點沒有預設值", output.ToString());
    }

    [Fact]
    public async Task CliDoesNotOverwriteExistingCapture()
    {
        var file = Path.GetTempFileName();
        try
        {
            await File.WriteAllTextAsync(file, "keep original");
            using var output = new StringWriter();
            var result = await CaptureCli.RunAsync(["--host", "127.0.0.1", "--port", "1", "--seconds", "1", "--output", file], output, CancellationToken.None);
            Assert.Equal(1, result);
            Assert.Equal("keep original", await File.ReadAllTextAsync(file));
        }
        finally { File.Delete(file); }
    }
}
