using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Text.Json.Serialization;
using Avalonia.Media.Imaging;

namespace MyApp
{
    [Serializable]
    public class Tile
    {
        public Tile(int tileNumber)
        {
            TileNumber = tileNumber;
        }

        //[JsonConstructor]
        //public Tile(Bitmap bitmap, int X, int Y, int tileNumber)
        //{
        //    BitmapTile = bitmap;
        //    XStart = X;
        //    YStart = Y;
        //    TileNumber = tileNumber;
        //}

        [JsonIgnore]
        public System.Drawing.Bitmap? BitmapTile { get; set; }

        public int DX { get; set; }

        public int DY { get; set; }

        public int TileNumber { get; set; }

        public Avalonia.Rect rect()
        {
            return new Avalonia.Rect(DX, DY, 64, 64);
        }


        public Avalonia.Media.Imaging.Bitmap ConvertToAvaloniaBitmap()
        {
            System.Drawing.Bitmap bitmapTmp = new System.Drawing.Bitmap(BitmapTile);
            var bitmapdata = bitmapTmp.LockBits(new Rectangle(0, 0, bitmapTmp.Width, bitmapTmp.Height), ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
            Avalonia.Media.Imaging.Bitmap bitmap1 = new Avalonia.Media.Imaging.Bitmap(Avalonia.Platform.PixelFormat.Bgra8888, Avalonia.Platform.AlphaFormat.Premul,
                bitmapdata.Scan0,
                new Avalonia.PixelSize(bitmapdata.Width, bitmapdata.Height),
                new Avalonia.Vector(96, 96),
                bitmapdata.Stride);
            bitmapTmp.UnlockBits(bitmapdata);
            bitmapTmp.Dispose();
            return bitmap1;
        }
    }
}
