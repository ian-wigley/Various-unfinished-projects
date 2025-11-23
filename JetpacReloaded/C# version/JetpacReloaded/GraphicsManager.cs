using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace JetPacReloaded
{
    public class GraphicsManager
    {
        private const int tileRowCount = 20;
        private const int tileColCount = 43;
        private List<Tile> m_tileList = new List<Tile>();

        public void LoadLevels()
        {
            int count = 0;
            string wordLine;
            const int unGroTileHeight = 48;
            const int unGroTileWidth = 62;
            try
            {
                StreamReader wordFile = new StreamReader(Directory.GetCurrentDirectory() + "/levels.txt");
                while ((wordLine = wordFile.ReadLine()) != null)
                {
                    string[] mFileContents = wordLine.Split(new Char[] { ',' });
                    for (int i = 0; i < tileColCount - 1; i++)
                    {
                        // Animated tiles contain 'a'
                        if (mFileContents[i].Contains('a'))
                        {
                            string[] animationDetail = mFileContents[i].Split(new Char[] { '.' });
                            int j = int.Parse(animationDetail[0]);
                            TileList.Add(new TileAnimation(int.Parse(animationDetail[0]), i * unGroTileWidth,
                                count * unGroTileHeight, int.Parse(animationDetail[2]), GetTileType(j)));
                        }
                        else
                        {
                            var value = int.Parse(mFileContents[i]);
                            LevelTiles[count, i] = value;
                            if (value != 0)
                            {
                                TileList.Add(new TileNoAnimation(value, i * unGroTileWidth, count * unGroTileHeight,
                                    GetTileType(value)));
                            }
                        }
                    }

                    count++;
                }

                wordFile.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine("The following error occured while attempting to read the file: " + e.Message);
            }
            //           WriteDebugInformation();
        }

        public void WriteDebugInformation()
        {
            File.WriteAllLines(Directory.GetCurrentDirectory() + "\\Debug.txt",
                TileList.Select(i =>
                    "Tile X : " + i.TileRect.X + ", Tile Y : " + i.TileRect.Y + ", Tile Type " +
                    i.GetTileCollisionType));
        }


        private TileCollisionType GetTileType(int value)
        {
            if (value is >= 1 and <= 4)
            {
                return TileCollisionType.Wall;
            }

            return value is >= 5 and <= 8 ? TileCollisionType.Platform : TileCollisionType.Impassable;
        }

        private int[,] LevelTiles { get; } = new int[tileRowCount, tileColCount];

        public List<Tile> TileList { get; } = [];
    }
}