import { Tile, TileCollisionType } from "./tile.js";
import { TileAnimation } from "./tileanimation.js";
import { TileNoAnimation } from "./tilenoanimation.js";

export class LevelManager {
    // private static tileRowCount: number = 20;
    // private static tileColCount: number = 43;
    // private m_tileList = [];
    public LevelTiles = [];
    public TileList = [];

    public LoadLevels(): void {
        let count: number = 0;
        let unGroTileHeight: number = 48;
        let unGroTileWidth: number = 62;
        let levelBytes: string;
        let path: string = "../Content/levels/levels.txt";
        let _this = this;

        try {

            let xhr = new XMLHttpRequest();
            xhr.open('GET', path, true);
            xhr.responseType = 'text';

            xhr.onload = function () {
                levelBytes = this.response;
            };
            xhr.onloadend = function () {
                let delimeter = (navigator.platform == "Win32") ? "\r\n" : "\n";
                let lineLevelData = levelBytes.split(delimeter);
                lineLevelData.forEach(l => {
                    let values = l.split(',');
                    let d = [];
                    let i: number = 0;
                    values.forEach(value => {
                        let v: number = + value;
                        if (value != 'a') {
                            d.push(v);
                            if (v != 0) {
                                let t = new TileNoAnimation(v, i * unGroTileWidth, count * unGroTileHeight, _this.GetTileType(v));
                                _this.TileList.push(t);
                            }
                        }
                        i += 1;
                    });
                    _this.LevelTiles.push(d);
                    count += 1;
                });

                // console.log("Done!");

                //     if (mFileContents[i].Contains('a')) {
                //         let animationDetail: string[] = mFileContents[i].Split('.');
                //         let j: number = number.Parse(animationDetail[0]);
                //         this.TileList.Add(new TileAnimation(number.Parse(animationDetail[0]), i * unGroTileWidth, count * unGroTileHeight, number.Parse(animationDetail[2]), this.GetTileType(j)));
                //     }
                //     else {
                //         let value = number.Parse(mFileContents[i]);
                //         this.LevelTiles[count, i] = value;
                //         if (value != 0) {
                //             this.TileList.Add(new TileNoAnimation(value, i * unGroTileWidth, count * unGroTileHeight, this.GetTileType(value)));
                //         }
                //     }
                // }

            };
            xhr.send();
        }
        catch (e) {
            console.log("The following error occured while attempting to read the file: " + e.Message);
        }
    }

    private GetTileType(value: number): TileCollisionType {
        if (value >= 1 && value <= 4) {
            return TileCollisionType.Wall;
        }
        if (value >= 5 && value <= 8) {
            return TileCollisionType.Platform;
        }
        else {
            return TileCollisionType.Impassable;
        }
    }
}