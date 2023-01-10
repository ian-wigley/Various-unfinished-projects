// using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace MyApp
{
    [Serializable]
    public class Screen
    {
        public Screen()
        {
            InitaliseTiles();
        }

        public void InitaliseTiles()
        {
            for (int i = 0; i < 140; i++)
            {
                Tiles.Add(new Tile(4));
            }
        }

        public string GetDataAsString(int count)
        {
            StringBuilder sb = new StringBuilder();
            for (int j = count; j < 14 + count; j++)
            {
                sb.Append(Tiles[j].TileNumber + ",");
            }
            return sb.ToString();
        }

        public string GetDataAsJsonString()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{ \"rectangleList\": [],");
            sb.Append("\"tiles\": [ {");

            //"tiles": [
            //{
            //    "_comment": "Upper Rocks",
            //    "sx": 0,
            //    "sy": 0,
            //    "sw": 100,
            //    "sh": 117,
            //    "dx": 0,
            //    "dy": 170,
            //    "dw": 100,
            //    "dh": 117
            //},

            for (int i = 0; i < Tiles.Count; i += 14)
            {
                for (int j = i; j < 14 + i; j++)
                {
                    // Ignore empty tiles
                    if (Tiles[j].TileNumber != 4)
                    {
                        sb.Append(Tiles[j].TileNumber + ",");
                    }
                }
            }
            sb.Append("] }");
            return sb.ToString();
        }



        // [JsonIgnore]
        public List<Tile> Tiles { get; private set; } = new List<Tile>();
    }
}
