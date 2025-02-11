using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Diagnostics;
using System.Drawing.Imaging;
using System.Collections.Generic;

namespace Posit
{
    public partial class Form1 : Form
    {
        private Bitmap bracketBitmap = new Bitmap("bracket.PNG");
        private Bitmap newBitmap = null;
        private List<Color> pixelColour = new List<Color>();

        public Form1()
        {
            InitializeComponent();
            newBitmap = MakeGrayscale(bracketBitmap);
        }



        private void Form1_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.DrawImage(newBitmap,0,0);//bracketBitmap, 0, 0);

            Graphics g = e.Graphics;
            Point p1 = new Point(0,50);
            Point p2 = new Point(50,50);
            using (Pen pen = new Pen(Color.Red, 5))
            {
                g.DrawLine(pen, p1, p2);
            }
           
        }

        // Method to parse each pixel and convert it 'GreyScale'
        private Bitmap MakeGrayscale(Bitmap original)//public static
        {
            //make an empty bitmap the same size as original
            Bitmap newBitmap = new Bitmap(original.Width, original.Height);

            for (int i = 0; i < original.Width; i++)
            {
                for (int j = 0; j < original.Height; j++)
                {
                    //get the pixel from the original image
                    Color originalColor = original.GetPixel(i, j);

                    //create the grayscale version of the pixel
                    int grayScale = (int)((originalColor.R * .3) + (originalColor.G * .59)
                        + (originalColor.B * .11));

                    //create the color object
                    Color newColor = Color.FromArgb(grayScale, grayScale, grayScale);

                    // ignore transparency
                    if (newColor.R != 0 && newColor.G != 0 && newColor.B != 0)
                    {
                        pixelColour.Add(newColor);
                    }

                    //set the new image's pixel to the grayscale version
                    newBitmap.SetPixel(i, j, newColor);

                }
            }
            newBitmap.PixelFormat.Equals(PixelFormat.Format8bppIndexed);
            return newBitmap;
        }


    }
}
