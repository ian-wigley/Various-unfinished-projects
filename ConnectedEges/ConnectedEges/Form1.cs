using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace ConnectedEges
{
    public partial class Form1 : Form
    {

        struct LabelInfo
        {
            public int startX;
            public int endX;
            public int label;
        };

        bool draw = false;
        bool firstLine = false;
        private int[,] listLabel;



        public Form1()
        {
            InitializeComponent();
        }

        private void loadToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Title = "Map Maker";
            openFileDialog.InitialDirectory = @"*.*";
            openFileDialog.Filter = "Image files|*.bmp;*.png;*.jpg";
            openFileDialog.FilterIndex = 2;
            openFileDialog.RestoreDirectory = true;

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                Bitmap img = (Bitmap)Image.FromFile(openFileDialog.FileName);
                Bitmap features = new Bitmap(img.Width, img.Height);//, PixelFormat.Format1bppIndexed);

                //Ensure that it's a 32 bit per pixel file
                if (img.PixelFormat != PixelFormat.Format32bppPArgb)
                {
                    Bitmap temp = new Bitmap(img.Width, img.Height, PixelFormat.Format32bppPArgb);
                    Graphics g = Graphics.FromImage(temp);
                    g.DrawImage(img, new Rectangle(0, 0, img.Width, img.Height), 0, 0, img.Width, img.Height, GraphicsUnit.Pixel);
                    img.Dispose();
                    g.Dispose();
                    img = temp;
                }
                this.pictureBox1.Image = img;

                // Fill the Image with a solid brush
                using (Graphics gfx = Graphics.FromImage(features))
                using (SolidBrush brush = new SolidBrush(Color.FromArgb(255, 255, 255)))
                {
                    gfx.FillRectangle(brush, 0, 0, features.Width, features.Height);
                }

                this.pictureBox2.Image = features;

                // Run the connected component labelling algorithm
                ConnectedComponentLabelling(img);

            }
        }

        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            this.toolStripStatusLabel2.Text = e.X.ToString();
            this.toolStripStatusLabel4.Text = e.Y.ToString();
            Invalidate();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void pictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            // Get the mouse position

            int startX = e.X;
            int startY = e.Y;

            int x = e.X;
            int y = e.Y;

            Bitmap b = new Bitmap(pictureBox1.Image);
            Bitmap m = new Bitmap(pictureBox2.Image);

            Color color4 = b.GetPixel(x, y);

            if (color4.R == 255 && color4.G == 255 && color4.B == 255)
            {
                toolStripStatusLabel5.Text = "White";
            }
            else
            {
                draw = true;
                toolStripStatusLabel5.Text = "Not White";

                // Get the label of the selected component & draw it
                int value = listLabel[y, x];

                for (int i = 0; i < m.Height; i++)
                {
                    for (int j = 0; j < m.Width; j++)
                    {
                        if (listLabel[i, j] == value)
                        {
                            m.SetPixel(j, i, Color.Red);
                        }
                    }

                }

                pictureBox2.Image = m;
            }




            // Todo : Create Templates !!







        }

        private void Form1_Paint(object sender, PaintEventArgs e)
        {
        }

        // 4 way connectivity
        private void ConnectedComponentLabelling(Bitmap img)
        {
            int labelVal = 1;
            bool labelSwitch = false;

            LabelInfo nfo = new LabelInfo();
            List<LabelInfo> labelList = new List<LabelInfo>();

            listLabel = new int[img.Height, img.Width];
            //int[,] listLabel = new int[img.Height, img.Width];

            firstLine = true;
            //first pass
            for (int y = 1; y < img.Height; y++)
            {
                if (y == 47)
                {
                    int op = 0;

                }
                for (int x = 1; x < img.Width; x++)
                {

                    // Get the current pixel colour value
                    Color centreColour = img.GetPixel(x, y);

                    // Not backgound ?
                    if (centreColour.R != 255 && centreColour.G != 255 && centreColour.B != 255)
                    {
                        //listLabel[y, x] = 1;
                        Color westColour = img.GetPixel(x - 1, y);
                        Color northColour = img.GetPixel(x, y - 1);

                        // Does the pixel to the left (West) have the same value as the current pixel?
                        // Yes – We are in the same region. Assign the same label to the current pixel
                        // No – Check next condition
                        if (westColour.R == centreColour.R && westColour.G == centreColour.G && westColour.B == centreColour.B)
                        {
                            int tempVal = listLabel[y, x - 1];
                            listLabel[y, x] = tempVal;// labelVal;
                        }


                        // Do both pixels to the North and West of the current pixel have the same value as the current pixel but not the same label?
                        // Yes – We know that the North and West pixels belong to the same region and must be merged. Assign the current pixel the minimum of the North and West labels, and record their equivalence relationship
                        // No – Check next condition
                        if (northColour.R == centreColour.R && northColour.G == centreColour.G && northColour.B == centreColour.B &&
                            westColour.R == centreColour.R && westColour.G == centreColour.G && westColour.B == centreColour.B)
                        {
                            int westLabel = listLabel[y, x - 1];
                            int northLabel = listLabel[y - 1, x];
                            if (westLabel != labelVal && northLabel != labelVal)
                            {
                                if (westLabel < northLabel)
                                {
                                    listLabel[y, x] = westLabel;
                                }
                                else
                                {
                                    listLabel[y, x] = northLabel;
                                }
                            }
                            else
                            {
                                listLabel[y, x] = labelVal;
                            }
                        }



                        // Does the pixel to the left (West) have a different value and the one to the North the same value as the current pixel?
                        // Yes – Assign the label of the North pixel to the current pixel
                        // No – Check next condition
                        if (northColour.R == centreColour.R && northColour.G == centreColour.G && northColour.B == centreColour.B &&
                            westColour.R != centreColour.R && westColour.G != centreColour.G && westColour.B != centreColour.B)
                        {
                            int tempVal = listLabel[y - 1, x];
                            listLabel[y, x] = tempVal;

                        }

                        //Do the pixel's North and West neighbors have different pixel values than current pixel?
                        //    Yes – Create a new label id and assign it to the current pixel
                        if (northColour.R != centreColour.R && northColour.G != centreColour.G && northColour.B != centreColour.B &&
                            westColour.R != centreColour.R && westColour.G != centreColour.G && westColour.B != centreColour.B)
                        {

                            labelVal += 1;
                            listLabel[y, x] = labelVal;

                        }
                    }
                    else
                    {
                        // Background
                        listLabel[y, x] = 0;

                    }
                }
                // End of initial scan of current line





                firstLine = false;
                // Union Join by finding neighbours - scan the line above
                // Not required for 1st line....
                if (!firstLine)
                {
                    int startX = 0;
                    int xx = 0;
                    int label = 0;

                    bool switcher = false;
                    for (int i = 0; i < img.Width; i++)
                    {

                        // Get the current pixel colour value
                        Color colour = img.GetPixel(i, y);
                        // If not background colour
                        if (colour.R != 255 && colour.G != 255 && colour.B != 255)
                        {
                            if (!switcher)
                            {
                                // record the start position
                                startX = i;
                                nfo.startX = i;
                            }

                            // Hit the first white
                            switcher = true;

                            // Get the pixel colour from line above
                            Color colourAbove = img.GetPixel(i, y - 1);
                            // If not background colour
                            if (colourAbove.R != 255 && colourAbove.G != 255 && colourAbove.B != 255)
                            {
                                label = listLabel[y - 1, i];
                                nfo.label = label;
                            }

                            xx++;

                        }
                        else
                        {
                            if (switcher)
                            {
                                // record the end of the line
                                nfo.endX = i;
                                switcher = false;

                                // Store the struct into the list
                                labelList.Add(nfo);
                            }
                        }


                    }

                }

            }


            // Parse structs......
            int breaker = 0;
            // Iterate through all of the structs
            for (int i = 0; i < labelList.Count - 2; i++)
            {
                //Compare the labels 1st
                if (labelList[i].label != labelList[i + 2].label)
                {
                    // Compare the x values to see if they overlap
                    for (int j = labelList[i].startX; j < labelList[i].endX; j++)
                    {
                        for (int k = labelList[i + 2].startX; k < labelList[i + 2].endX; k++)
                        {
                            if (k == j)
                            {
                                // Update label !
                                int update = 0;
                                j = labelList[i].endX;
                                k = labelList[i + 2].endX;

                                if (i > 1)
                                {
                                    if (labelList[i].label < labelList[i + 2].label)
                                    {
                                        LabelInfo lbl = labelList[i + 2];

                                        //lbl.label = labelList[i].label;

                                        int one = labelList[i].label;
                                        int two = labelList[i + 2].startX;
                                        int three = labelList[i + 2].endX;

                                        labelList.RemoveAt(i + 2);//.Remove(lbl);

                                        lbl.label = one;
                                        lbl.startX = two;
                                        lbl.endX = three;

                                        labelList.Insert(i + 2, lbl);
                                    }

                                }

                            }
                        }

                    }

                }
                //If no match get the start & end values for 

            }




            // 2nd pass
            for (int x = 1; x < img.Width; x++)
            {
                for (int y = 1; y < img.Height; y++)
                {
                    //Relabel the element with the lowest equivalent label

                    // Get the current label value
                    int currentVal = listLabel[y, x];
                    // check the value above
                    int northVal = listLabel[y - 1, x];

                    if (x == 19)
                    {
                        int a = 0;
                    }

                    // Check if its a backgound value
                    if (currentVal != 0 && northVal != 0)
                    {
                        if (currentVal > northVal)
                        {
                            listLabel[y, x] = northVal;
                        }

                    }

                }
            }

        }

    }
}
