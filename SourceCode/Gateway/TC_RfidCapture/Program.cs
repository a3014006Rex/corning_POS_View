using Corning.Pos.RfidCapture;

using var stop = new CancellationTokenSource();
Console.CancelKeyPress += (_, args) => { args.Cancel = true; stop.Cancel(); };
return await CaptureCli.RunAsync(args, Console.Out, stop.Token);
