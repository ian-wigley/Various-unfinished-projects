using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;

namespace MyApp
{
    public class FileManager
    {
        private const int mTileWidth = 62;
        private const int mTileHeight = 49;
        private readonly int numOfEditorButtons = 0;
        private readonly Bitmap? m_enemyBitmap;
        private readonly Bitmap? m_standardLevelTiles;
        private Rectangle cloneRect = new Rectangle(0, 0, 62, 49);
        private readonly List<Screen> screens;

        public FileManager() { 
            screens = new List<Screen>();
        }

        public FileManager(List<Screen> screen, int numButtons, Bitmap enemyBitmap, Bitmap standardLevelTiles)
        {
            screens = screen;
            numOfEditorButtons = numButtons;
            m_enemyBitmap = enemyBitmap;
            m_standardLevelTiles = standardLevelTiles;
        }

        public void ImportTextFile(string fileName)
        {
            int y = 30;
            int levelNumber = 0;
            int counterOfTilesPerLevel = 0;
            string wordLine;
            try
            {
                StreamReader? wordFile = new StreamReader(fileName);
                // var t = wordFile.ReadLine();

                while ((wordLine = wordFile.ReadLine()) != null)
                {
                    ConvertToTiles(wordLine, ref y, ref levelNumber, ref counterOfTilesPerLevel);
                }
                wordFile.Close();
            }
            catch (Exception e)
            {
                // MessageBox.Show("The following error occured while attempting to read the file: " + e.Message);
                Console.WriteLine(e.Message);
            }
        }

        public void ImportJSONFile(string fileName)
        //public List<Screen> ImportJSONFile(string fileName)
        {
            // StreamReader wordFile;

            // try
            // {
            //     wordFile = new StreamReader(fileName);
            //     if (wordFile != null)
            //     {
            //         // set deserializer to replace default items that are created by the 
            //         // constructors, otherwise you will end up with duplicates
            //         JsonSerializerSettings settings = new JsonSerializerSettings();
            //         settings.ObjectCreationHandling = ObjectCreationHandling.Replace;

            //         string json = wordFile.ReadToEnd();
            //         //screens = JsonConvert.DeserializeObject<List<string>>(json, settings);
            //         var t = JsonConvert.DeserializeObject<List<string>>(json, settings);

            //         // draw the tiles
            //         foreach (Screen screen in screens)
            //         {
            //             //foreach (Row row in screen.Rows)
            //             //{
            //             //foreach (Tile tile in row.Tiles)
            //             //{
            //             //    // ignore empty tiles
            //             //    if (tile.AsciiCode != "4")
            //             //    {
            //             //        Rectangle rect = getRect(tile.AsciiCode);

            //             //        if (tile.Type == "enemy")
            //             //        {
            //             //            cloneBitmap = enemyBitmap.Clone(rect, myBitmap.PixelFormat);
            //             //        }
            //             //        else
            //             //        {
            //             //            cloneBitmap = myBitmap.Clone(rect, myBitmap.PixelFormat);
            //             //        }

            //             //        tile.BitmapTile = cloneBitmap;
            //             //    }
            //             //}
            //             //}
            //         }

            //         wordFile.Close();
            //         wordFile.Dispose();
            //     }
            // }// using Newtonsoft.Json;
            // catch (Exception e)
            // {
            //     // MessageBox.Show("The following error occured while attempting to read the file: " + e.Message);
            // }
            // //return screens;
        }

        private void ConvertToTiles(string wordLine, ref int y, ref int levelNumber, ref int counterOfTilesPerLevel)
        {
            int x = 0;
            int temp;
            bool enemyTile;
            string[] rowOfTiles = wordLine.Split(new Char[] { ',' });

            for (int i = 0; i < rowOfTiles.Length - 1; i++)
            {
                int tileNumber = int.Parse(rowOfTiles[i]);

                if (tileNumber != 4)
                {
                    if (tileNumber < 80)
                    {
                        enemyTile = false;
                        temp = tileNumber;
                    }
                    else
                    {
                        enemyTile = true;
                        temp = tileNumber;
                        tileNumber -= 80;
                    }

                    if (tileNumber < numOfEditorButtons && !enemyTile)
                    {
                        cloneRect = new Rectangle(mTileWidth * temp, mTileHeight * 0, mTileWidth, mTileHeight);
                        AddTile(x, y, tileNumber, counterOfTilesPerLevel, levelNumber, enemyTile);
                    }
                    if (tileNumber < numOfEditorButtons && enemyTile)
                    {
                        cloneRect = new Rectangle(mTileWidth * tileNumber, mTileHeight * 0, mTileWidth, mTileHeight);
                        AddTile(x, y, temp, counterOfTilesPerLevel, levelNumber, enemyTile);
                    }
                    else if (tileNumber >= numOfEditorButtons && tileNumber < (numOfEditorButtons * 2))
                    {
                        temp = tileNumber - (numOfEditorButtons * 1);
                        cloneRect = new Rectangle(mTileWidth * temp, mTileHeight * 1, mTileWidth, mTileHeight);
                        AddTile(x, y, tileNumber, counterOfTilesPerLevel, levelNumber, enemyTile);
                    }
                    else if (tileNumber >= (numOfEditorButtons * 2) && tileNumber < (numOfEditorButtons * 3))
                    {
                        temp = tileNumber - (numOfEditorButtons * 2);
                        cloneRect = new Rectangle(mTileWidth * temp, mTileHeight * 2, mTileWidth, mTileHeight);
                        AddTile(x, y, tileNumber, counterOfTilesPerLevel, levelNumber, enemyTile);
                    }
                    else if (tileNumber >= (numOfEditorButtons * 3) && tileNumber < (numOfEditorButtons * 4))
                    {
                        temp = tileNumber - (numOfEditorButtons * 3);
                        cloneRect = new Rectangle(mTileWidth * temp, mTileHeight * 3, mTileWidth, mTileHeight);
                        AddTile(x, y, tileNumber, counterOfTilesPerLevel, levelNumber, enemyTile);
                    }
                }
                x += mTileWidth;
                counterOfTilesPerLevel++;
            }
            y += mTileHeight;

            if (counterOfTilesPerLevel == 140)
            {
                levelNumber++;
                y = 30;
                counterOfTilesPerLevel = 0;
            }
        }


        private void AddTile(int x, int y, int tileNumber, int count, int level, bool enemy)
        {
            Bitmap cloneBitmap;
            if (!enemy)
            {
                cloneBitmap = m_standardLevelTiles.Clone(cloneRect, m_standardLevelTiles.PixelFormat);
            }
            else
            {
                cloneBitmap = m_enemyBitmap.Clone(cloneRect, m_enemyBitmap.PixelFormat);
            }
            // screens[level].Tiles[count].BitmapTile = cloneBitmap;
            // screens[level].Tiles[count].DX = x;
            // screens[level].Tiles[count].DY = y;
            // screens[level].Tiles[count].TileNumber = tileNumber;
        }

        public void ExportTextFile(string fileName)
        {
            int count = 0;
            string[] lineToOutput = new string[1];
            try
            {
                StreamWriter outputFile = new StreamWriter(fileName, false);
                foreach (Screen screen in screens)
                {
                    for (int i = 0; i < screen.Tiles.Count; i += 14)
                    {
                        lineToOutput[0] = screen.GetDataAsString(i) + "//" + count.ToString();
                        outputFile.WriteLine(lineToOutput[0]);
                    }
                    count++;
                }
                outputFile.Close();
            }
            catch (Exception e)
            {
                // MessageBox.Show("Exception occurred while saving file: " + e.ToString());
                Console.WriteLine("Exception occurred while saving file: " + e.Message);
            }
        }


        //  [ {
        //      "rectangleList": [],
        //"enemies": [],
        //      "name": "AboveMoonScreen0",
        //      "comment": "sx, sy.. start x, y : dx, dy.. => destination x, y ..",
        //      "tiles": [
        //          {
        //              "_comment": "Upper Rocks",
        //              "sx": 0,
        //              "sy": 0,
        //              "sw": 100,
        //              "sh": 117,
        //              "dx": 0,
        //              "dy": 170,
        //              "dw": 100,
        //              "dh": 117
        //          }
        //        ]
        //      }
        //    ]

        public void ExportJsonFile(string fileName)
        {
            //int count = 0;
            // StreamWriter? outputFile = null;
            // JsonSerializer jsonSerializer = new JsonSerializer();
            // List<string> tempTileData = new List<string>();
            // try
            // {
            //     outputFile = new StreamWriter(fileName, false);
            //     if (outputFile != null)
            //     {

            //         tempTileData.Add(screens[0].GetDataAsJsonString());

            //         //foreach (Screen screen in screens)
            //         //{
            //         //    tempTileData.Add(screen.GetDataAsJsonString());
            //         //    //for (int i = 0; i < screen.Tiles.Count; i += 14)
            //         //    //{
            //         //    //    tempTileData.Add(screen.GetDataAsJsonString(i)); // + "//" + count.ToString());
            //         //    //}
            //         //    //count++;
            //         //}
            //         ////tempTileData.Add("}");
            //         string jsonData = JsonConvert.SerializeObject(tempTileData);
            //         outputFile.Write(jsonData);
            //         outputFile.Close();
            //     }
            // }
            // catch (Exception e)
            // {
            //     // MessageBox.Show("Exception occurred while saving file: " + e.ToString());
            // }
            // finally
            // {
            //     if (outputFile != null)
            //     {
            //         outputFile.Close();
            //         outputFile.Dispose();
            //     }
            // }
        }
    }
}