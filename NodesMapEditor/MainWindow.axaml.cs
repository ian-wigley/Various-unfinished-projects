using System;
using System.Collections.Generic;
using Avalonia.Media.Imaging;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia;
using SkiaSharp;
using System.IO;
using Avalonia.Media;

namespace MyApp;

public partial class MainWindow : Window
{

    // private int m_asciiCode;
    // private int m_gridSquareNmber = 0;
    private int m_level = 0;
    // private int m_screenshotStartX;
    // private int m_screenshotStartY;
    private int m_tileWidth = 62;
    private int m_tileHeight = 49;
    private int m_noOfScreens = 256;
    // private int m_screenDisplayX;
    // private int m_screenDisplayY;

    private const int m_numButtonsX = 19;
    private const int m_numButtonsY = 4;
    private const int m_numberOfEnemyButtons = 9;
    private const int m_numberOfLevelButtons = 76;

    // private bool m_areMoving = false;
    // private bool m_platforms = true;
    private System.Drawing.Bitmap? m_standardEnemyTiles = new System.Drawing.Bitmap("assets/enemy_tiles.png");
    // private Bitmap m_smallEnemyButtonTiles = new Bitmap("assets/enemy_tiles_small.png");
    private System.Drawing.Bitmap? m_standardLevelTiles = new System.Drawing.Bitmap("assets/underground_tiles_small.png");
    // private SkiaSharp.SKBitmap m_smallLevelButtonTiles = new SkiaSharp.SKBitmap(("assets/underground_tiles.png");
    // private Bitmap m_cloneScreenDisplay;
    // private Bitmap m_cloneEnemyDisplay;
    // private Bitmap m_cloneBitmap;
    // private System.Drawing.Bitmap m_grid;// = new System.Drawing.Bitmap(808, 640);
    // private Rectangle m_buttonRect;
    // private Rectangle m_cloneRect = new Rectangle(0, 0, 62, 49);
    // private Rectangle m_redraw = new Rectangle(0, 30, 1808, 900);

    private Point m_gridPos = new Point(0, 0);

    private readonly FileManager? m_fileManager;

    // private readonly Button[] m_levelButton;
    // private readonly Button[] m_enemyButton;

    private readonly List<Bitmap> m_levelButtons = new List<Bitmap>();
    private readonly List<Bitmap> m_enemyButtons = new List<Bitmap>();
    private readonly List<Screen> m_screens = new List<Screen>();
    readonly Random random = new Random();

    public MainWindow()
    {
        InitializeComponent();
        // CreateBitmapGrid();
        for (int i = 0; i < m_noOfScreens; i++)
        {
            m_screens.Add(new Screen());
            // screenNumbers.Items.Add(i);
            // screenNumbers.Text = "0";
        }
        // m_fileManager = new FileManager();
        // m_fileManager = new FileManager(m_screens, m_numButtonsX);
        m_fileManager = new FileManager(m_screens, m_numButtonsX, m_standardEnemyTiles, m_standardLevelTiles);
        // testCanvas.PreviewMouseMove += this.MouseMove;
        // this.AddHandler(PointerPressedEvent, MouseDownHandler, handledEventsToo: true);
        // this.AddHandler(PointerReleasedEvent, MouseUpHandler, handledEventsToo: true);
    }


    // private void MouseUpHandler(object sender, PointerReleasedEventArgs e)
    // {
    //     System.Diagnostics.Debug.WriteLine("Mouse released.");
    // }

    // private void MouseDownHandler(object sender, PointerPressedEventArgs e)
    // {
    //     System.Diagnostics.Debug.WriteLine("Mouse pressed.");
    // }

    //https://docs.avaloniaui.net/docs/controls/menu
    private async void OpenMenuItem_Click(object sender, RoutedEventArgs e)
    {
        var parent = this;//(Window)sender;//.GetVisualRoot();

        OpenFileDialog? dialog = new OpenFileDialog();
        dialog.Filters.Add(new FileDialogFilter() { Name = "Text", Extensions = { "txt" } });
        dialog.Directory = Directory.GetCurrentDirectory();
        string[]? result = await dialog.ShowAsync(this);

        if (result != null && result.Length > 0)
        {
            if (result[0].ToLower().Contains("txt"))
            {
                m_fileManager.ImportTextFile(result[0]);
            }
            if (result[0].ToLower().Contains("json"))
            {
                m_fileManager.ImportJSONFile(result[0]);
            }
        }
        InvalidateVisual();
    }

    private async void SaveMenuItem_Click(object sender, RoutedEventArgs e)
    {
        SaveFileDialog? saveFileDialog = new SaveFileDialog() ?? throw new ArgumentException("Save File Dialog Failed");
        if (null == saveFileDialog)
        {
            throw new Exception("Save File Dialog Failed");
        }
        else
        {
            saveFileDialog.Filters.Add(new FileDialogFilter() { Name = "Text", Extensions = { "txt" } });
            string? result = await saveFileDialog.ShowAsync(this);

            //     {
            //         Title = "Map Maker",
            //         // InitialDirectory = @"*.*",
            //         // Filters = "All files (*.*)|*.*|Text (*.txt)|*.txt|Json (*.json)|*.json",
            //         // FilterIndex = 2,
            //         // RestoreDirectory = true
            //     };

            if (result != null && result.Length > 0)
            {
                if (result.ToLower().Contains("txt"))
                {
                    m_fileManager.ExportTextFile(result);
                }
                else if (result.ToLower().Contains(".json"))
                {
                    // m_fileManager.ExportJsonFile(result[0]);
                }
            }
        }
    }

    private void menuExit_Click(object sender, RoutedEventArgs e)
    {
        this.Close();
    }

    // public void MyButton_Click(object sender, RoutedEventArgs e)
    // {
    //     // Handle click here.
    //     int i = 0;
    //     i++;
    // }


    // // Create a bitmap grid
    // private void CreateBitmapGrid()
    // {
    //     // Horizontal Lines
    //     for (int X = 0; X < (13 * m_tileWidth); X++)
    //     {
    //         for (int Y = 30; Y < (11 * m_tileHeight); Y += m_tileHeight)
    //         {
    //             //LineGeometry line1 = new LineGeometry(new Point(-100, 150), new Point(1000, 150));
    //             System.Diagnostics.Debug.WriteLine("X:" + X);
    //             System.Diagnostics.Debug.WriteLine("Y:" + Y);
    //         }
    //     }
    //     // // Vertical Lines
    //     // for (int X = 0; X < (14 * m_tileWidth); X += m_tileWidth)
    //     // {
    //     //     for (int Y = 30; Y < (10 * m_tileHeight) + 30; Y++)
    //     //     {
    //     //         System.Diagnostics.Debug.WriteLine("X:" + X);
    //     //         System.Diagnostics.Debug.WriteLine("Y:" + Y);
    //     //     }
    //     // }
    // }

    // https://stackoverflow.com/questions/67536123/in-avaloniaui-how-to-display-an-image-from-a-web-url
    public override void Render(DrawingContext drawingContext)
    {
        int tileCount = 0;
        // drawingContext.DrawImage(m_grid, m_gridPos);

        foreach (Tile t in m_screens[m_level].Tiles)
        {
            if (m_screens[m_level].Tiles[tileCount].BitmapTile != null)
            {
                drawingContext.DrawImage(t.ConvertToAvaloniaBitmap(), t.rect());
            }
            if (tileCount == m_screens[m_level].Tiles.Count)
            {
                tileCount = 0;
            }
            tileCount += 1;
        }
    }
}