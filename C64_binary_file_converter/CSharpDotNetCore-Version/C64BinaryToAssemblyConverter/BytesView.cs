using System;
using System.Globalization;
using System.Text;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Controls.Primitives;
using Avalonia.Input;
using Avalonia.Layout;
using Avalonia.Media;
using Avalonia.Media.Imaging;
using Avalonia.Platform;

namespace C64BinaryToAssemblyConverter;

public class BytesView : Control
{
    private const int ColumnCount = 8;

    private static readonly Typeface AddressTypeface =
        new("Segoe UI");

    private static readonly Typeface HexTypeface =
        new("Consolas");

    private readonly ScrollBar _scrollBar;

    private byte[]? _dataBuf;
    private int _displayLinesCount;
    private int _linesCount;
    private readonly int _rowCount = 25;
    private int _startAddress;

    private int _startLine;

    public BytesView()
    {
        ClipToBounds = true;

        _scrollBar = new ScrollBar
        {
            Orientation = Orientation.Vertical
        };

        _scrollBar.PropertyChanged += (_, e) =>
        {
            if (e.Property == RangeBase.ValueProperty)
            {
                _startLine = (int)_scrollBar.Value;
                InvalidateVisual();
            }
        };
    }

    public override void Render(DrawingContext context)
    {
        base.Render(context);
        DrawClient(context);

        if (_dataBuf != null)
            DrawLines(context, _startLine, _displayLinesCount);
    }

    private void DrawClient(DrawingContext context)
    {
        var pen = new Pen(Brushes.Gray);

        context.DrawRectangle(
            null,
            pen,
            new Rect(74, 5, 537, _rowCount * 21));

        context.DrawLine(
            pen,
            new Point(474, 5),
            new Point(474, 5 + _rowCount * 21));
    }

    private void DrawLines(
        DrawingContext context,
        int startingLine,
        int linesCount)
    {
        for (var line = 0; line < linesCount; line++)
        {
            var buffer = ComposeLineBuffer(startingLine, line);

            DrawAddress(context, startingLine, line);
            DrawHex(context, buffer, line);
            DrawDump(context, buffer, line);

            if (buffer.Length == 8)
                DrawChar(context, buffer, line);
        }
    }

    private void DrawAddress(
        DrawingContext context,
        int startingLine,
        int line)
    {
        var text =
            $"{(startingLine + line) * ColumnCount:X4} " +
            $"{_startAddress + (startingLine + line) * ColumnCount:X4}";

        DrawText(
            context,
            text,
            AddressTypeface,
            12,
            new Point(5, 7 + line * 21));
    }

    private void DrawHex(
        DrawingContext context,
        byte[] data,
        int line)
    {
        var sb = new StringBuilder();

        for (var i = 0; i < data.Length; i++)
        {
            sb.Append(data[i].ToString("X2"));
            sb.Append(' ');

            if (i == ColumnCount / 2 - 1)
                sb.Append(' ');
        }

        DrawText(
            context,
            sb.ToString(),
            HexTypeface,
            12,
            new Point(76, 7 + line * 21));
    }

    private void DrawDump(
        DrawingContext context,
        byte[] data,
        int line)
    {
        var sb = new StringBuilder();

        foreach (var b in data)
        {
            var c = (char)b;
            sb.Append(char.IsControl(c) ? '.' : c);
        }

        DrawText(
            context,
            sb.ToString(),
            HexTypeface,
            12,
            new Point(379, 7 + line * 21));
    }

    private static void DrawText(
        DrawingContext context,
        string text,
        Typeface typeface,
        double size,
        Point position)
    {
        var formattedText =
            new FormattedText(
                text,
                CultureInfo.InvariantCulture,
                FlowDirection.LeftToRight,
                typeface,
                size,
                Brushes.Black);

        context.DrawText(formattedText, position);
    }


    private void DrawChar(
        DrawingContext context,
        byte[] lineBuffer,
        int line)
    {
        if (lineBuffer.Length != 8)
            return;

        var bitmap = CreateGlyph(lineBuffer);

        const int scale = 2;

        context.DrawImage(
            bitmap,
            new Rect(0, 0, 8, 8),
            new Rect(
                500,
                7 + line * 21,
                8 * scale,
                8 * scale));
    }

    private static WriteableBitmap CreateGlyph(byte[] data)
    {
        var bmp = new WriteableBitmap(
            new PixelSize(8, 8),
            new Vector(96, 96),
            PixelFormat.Bgra8888,
            AlphaFormat.Opaque);

        using var fb = bmp.Lock();

        // unsafe
        // {
        //     byte* ptr = (byte*)fb.Address;
        //
        //     for (int y = 0; y < 8; y++)
        //     {
        //         byte row = data[y];
        //
        //         for (int x = 0; x < 8; x++)
        //         {
        //             bool pixelOn = (row & (0x80 >> x)) != 0;
        //
        //             int offset =
        //                 y * fb.RowBytes +
        //                 x * 4;
        //
        //             byte color = pixelOn ? (byte)255 : (byte)0;
        //
        //             // BGRA
        //             ptr[offset + 0] = color; // B
        //             ptr[offset + 1] = color; // G
        //             ptr[offset + 2] = color; // R
        //             ptr[offset + 3] = 255;   // A
        //         }
        //     }
        // }

        return bmp;
    }

    private byte[] ComposeLineBuffer(
        int startingLine,
        int line)
    {
        var start = startingLine * ColumnCount;

        var result =
            start + (line + 1) * ColumnCount <= _dataBuf!.Length
                ? new byte[ColumnCount]
                : new byte[_dataBuf.Length % ColumnCount];

        for (var column = 0; column < result.Length; column++)
        {
            var index = line * ColumnCount + column;

            if (start + index < _dataBuf.Length)
                result[column] = _dataBuf[start + index];
        }

        return result;
    }

    public void SetBytes(byte[] bytes, int startingAddress)
    {
        _dataBuf = bytes;
        _startAddress = startingAddress;

        _linesCount =
            (bytes.Length + ColumnCount - 1) / ColumnCount;

        _displayLinesCount =
            Math.Min(_rowCount, _linesCount);

        InvalidateVisual();
    }

    protected override void OnPointerWheelChanged(
        PointerWheelEventArgs e)
    {
        base.OnPointerWheelChanged(e);

        _startLine -= (int)e.Delta.Y;

        if (_startLine < 0)
            _startLine = 0;

        if (_startLine > _linesCount - _rowCount)
            _startLine = Math.Max(0, _linesCount - _rowCount);

        InvalidateVisual();
    }
}