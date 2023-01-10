using System;
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
        public Bitmap BitmapTile { get; set; }

        public int DX { get; set; }

        public int DY { get; set; }

        public int TileNumber { get; set; }
    }
}
