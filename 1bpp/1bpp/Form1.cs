using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Runtime.InteropServices;

namespace _1bitmap
{
    /// <summary>
    /// Summary description for Form1.
    /// </summary>

    public class Form1 : System.Windows.Forms.Form
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>

        private System.ComponentModel.Container components = null;

        public Form1()
        {
            //
            // Required for Windows Form Designer support
            //
            InitializeComponent();
            //
            // TODO: Add any constructor code after InitializeComponent call
            //
            SetStyle(ControlStyles.ResizeRedraw, true);
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>

        /// Required method for Designer support - do not modify

        /// the contents of this method with the code editor.

        /// </summary>

        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.splitter1 = new System.Windows.Forms.Splitter();
            this.pictureBox2 = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).BeginInit();
            this.SuspendLayout();
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackColor = System.Drawing.Color.White;
            this.pictureBox1.Dock = System.Windows.Forms.DockStyle.Left;
            this.pictureBox1.ErrorImage = ((System.Drawing.Image)(resources.GetObject("pictureBox1.ErrorImage")));
            this.pictureBox1.Location = new System.Drawing.Point(0, 0);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(303, 397);
            this.pictureBox1.TabIndex = 0;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // splitter1
            // 
            this.splitter1.Location = new System.Drawing.Point(303, 0);
            this.splitter1.Name = "splitter1";
            this.splitter1.Size = new System.Drawing.Size(3, 397);
            this.splitter1.TabIndex = 1;
            this.splitter1.TabStop = false;
            // 
            // pictureBox2
            // 
            this.pictureBox2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.pictureBox2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pictureBox2.Location = new System.Drawing.Point(306, 0);
            this.pictureBox2.Name = "pictureBox2";
            this.pictureBox2.Size = new System.Drawing.Size(270, 397);
            this.pictureBox2.TabIndex = 2;
            this.pictureBox2.TabStop = false;
            // 
            // Form1
            // 
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.ClientSize = new System.Drawing.Size(576, 397);
            this.Controls.Add(this.pictureBox2);
            this.Controls.Add(this.splitter1);
            this.Controls.Add(this.pictureBox1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion


        /// <summary>
        /// The main entry point for the application.
        /// </summary>

        [STAThread]
        static void Main()
        {
            Application.Run(new Form1());
        }

        protected void SetIndexedPixel(int x, int y, BitmapData bmd, bool pixel)
        {
            int index = y * bmd.Stride + (x >> 3);
            byte p = Marshal.ReadByte(bmd.Scan0, index);
            byte mask = (byte)(0x80 >> (x & 0x7));
            if (pixel)
            {
                p |= mask;
            }
            else
            {
                p &= (byte)(mask ^ 0xff);
            }
            Marshal.WriteByte(bmd.Scan0, index, p);
        }

        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Splitter splitter1;
        private System.Windows.Forms.PictureBox pictureBox2;
        Bitmap bm;

        private void Form1_Load(object sender, System.EventArgs e)
        {
        }

        private void pictureBox1_Click(object sender, System.EventArgs e)
        {
            //Load a file
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.Filter = "Image files|*.bmp;*.gif;*.jpg";
            if (dlg.ShowDialog() == DialogResult.OK)
            {
                Bitmap img = (Bitmap)Image.FromFile(dlg.FileName);
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
                //lock the bits of the original bitmap
                BitmapData bmdo = img.LockBits(new Rectangle(0, 0, img.Width, img.Height), ImageLockMode.ReadOnly, img.PixelFormat);

                //and the new 1bpp bitmap
                bm = new Bitmap(this.pictureBox1.Image.Width, this.pictureBox1.Image.Height, PixelFormat.Format1bppIndexed);
                BitmapData bmdn = bm.LockBits(new Rectangle(0, 0, bm.Width, bm.Height), ImageLockMode.ReadWrite, PixelFormat.Format1bppIndexed);

                //for diagnostics
                DateTime dt = DateTime.Now;

                //scan through the pixels Y by X
                int x, y;
                for (y = 0; y < img.Height; y++)
                {
                    for (x = 0; x < img.Width; x++)
                    {
                        //generate the address of the colour pixel
                        int index = y * bmdo.Stride + (x * 4);

                        //check its brightness
                        if (Color.FromArgb(Marshal.ReadByte(bmdo.Scan0, index + 2),
                              Marshal.ReadByte(bmdo.Scan0, index + 1),
                              Marshal.ReadByte(bmdo.Scan0, index)).GetBrightness() > 0.5f)
                        {
                            this.SetIndexedPixel(x, y, bmdn, true); //set it if its bright.
                        }
                    }
                }

                //tidy up
                bm.UnlockBits(bmdn);
                img.UnlockBits(bmdo);

                //show the time taken to do the conversion
                TimeSpan ts = dt - DateTime.Now;
                System.Diagnostics.Trace.WriteLine("Conversion time was:" + ts.ToString());
                //display the 1bpp image.
                this.pictureBox2.Image = bm;
            }
        }
    }
}



/*
algorithm TwoPass(data)
   linked = []
   labels = structure with dimensions of data, initialized with the value of Background
   
   First pass
   
   for row in data:
       for column in row:
           if data[row][column] is not Background
               
               neighbors = connected elements with the current element's value
               
               if neighbors is empty
                   linked[NextLabel] = set containing NextLabel                    
                   labels[row][column] = NextLabel
                   NextLabel += 1
               
               else
                   
                   Find the smallest label
                   
                   L = neighbors labels
                   labels[row][column] = min(L)
                   for label in L
                       linked[label] = union(linked[label], L)
   
   Second pass
   
   for row in data
       for column in row
           if data[row][column] is not Background         
               labels[row][column] = find(labels[row][column])      
      
   return labels

*/


/*
One-Pass(Image)
            [M, N]=size(Image);
            Connected = zeros(M,N);
            Mark = Value;
            Difference = Increment;
            Offsets = [-1; M; 1; -M];
            Index = [];
            No_of_Objects = 0; 
   
   for i: 1:M :
       for j: 1:N:
            if(Image(i,j)==1)            
                 No_of_Objects = No_of_Objects +1;            
                 Index = [((j-1)*M + i)];           
                 Connected(Index)=Mark;            
                 while ~isempty(Index)                
                      Image(Index)=0;                
                      Neighbors = bsxfun(@plus, Index, Offsets');
                      Neighbors = unique(Neighbors(:));                
                      Index = Neighbors(find(Image(Neighbors)));                                
                      Connected(Index)=Mark;
                 end            
                 Mark = Mark + Difference;
            end
      end
  end
*/