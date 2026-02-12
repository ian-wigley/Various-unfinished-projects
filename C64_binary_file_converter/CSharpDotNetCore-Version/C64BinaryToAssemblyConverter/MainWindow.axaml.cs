using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Threading.Tasks;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;
using Avalonia.Platform.Storage;

namespace C64BinaryToAssemblyConverter;

//https://github.com/AvaloniaCommunity/MessageBox.Avalonia

public partial class MainWindow : Window
{
    private byte[] _data;
    private readonly AssemblyCreator _assemblyCreator;
    private readonly Parser _parser = new();
    private List<string> _lineNumbers = [];
    private List<string> _illegalOpcodes = [];
    private Dictionary<string, string[]> _dataStatements = new Dictionary<string, string[]>();
    private int _userDefinedStartAddress;

    public MainWindow()
    {
        InitializeComponent();
        //byteviewer.SetDisplayMode(DisplayMode.Hexdump);
        //MaximizeBox = false;
        //MinimizeBox = false;
        GenerateLabels.IsEnabled = false;
        //LeftWindowMenuItem.Enabled = false;
        //RightWindowMenuItem.Enabled = false;
        PopulateOpCodeList.Init();
        _assemblyCreator = new AssemblyCreator();
    }

    /// <summary>
    /// Add Labels
    /// </summary>
    private void AddLabels(
        int delta,
        string start,
        string end,
        bool replaceIllegalOpcodes,
        Dictionary<string, string[]> replacedWithDataStatements)
    {
        RightTextBox.Clear();
        // ClearRightWindow();
        RightTextBox.FontFamily = new FontFamily("Consolas");
        _assemblyCreator.InitialPass(delta, end, replaceIllegalOpcodes, replacedWithDataStatements, _parser.Code);
        _assemblyCreator.SecondPass(_parser.Code);
        // RightTextBox.Lines = _assemblyCreator.FinalPass(_parser.Code, start).ToArray();
        var lines = _assemblyCreator.FinalPass(_parser.Code, start).ToArray();
        foreach (var line in lines)
        {
            RightTextBox.Text += line + "\n";            
        }
        // RightWindowMenuItem.Enabled = true;
    }


    private async void OpenMenuItem(object sender, RoutedEventArgs e)
    {
        var files = await OpenFileDialog();
        if (files.Count == 0) return;
        ClearCollections();

        var ml = new LoadIntoMemoryLocationSelector();
        var startLocation = await ml.ShowDialog<string?>(this);
        if (startLocation == null) { return; }
        
        // Use a monospaced font
        LeftTextBox.FontFamily = new FontFamily("Consolas");
        if (!int.TryParse(startLocation, NumberStyles.HexNumber, null, out var startAddress)) { return; }
        _userDefinedStartAddress = startAddress;
        _data = _parser.LoadBinaryData(files[0].Path.AbsolutePath);

        var lines  = _parser.ParseFileContent(_data, LeftTextBox, startAddress, ref _lineNumbers);
        foreach (var line in lines)
        {
            LeftTextBox.Text += line + "\n";            
        }

        // _dataStatements = _parser.DataStatements;
        // _illegalOpcodes = _parser.IllegalOpCodes;

        GenerateLabels.IsEnabled = true;
        // LeftWindowMenuItem.Enabled = true;
        // //byteviewer.SetFile(openFileDialog.FileName, startAddress);
        // byteviewer.SetFile(openFileDialog.FileName);
        // FileLoaded.Text = openFileDialog.SafeFileName;
        // FileLoaded.Left = 340;

        InvalidateVisual();
    }

    private async Task<IReadOnlyList<IStorageFile>> OpenFileDialog()
    {
        var topLevel = GetTopLevel(this);
        var files = await topLevel.StorageProvider.OpenFilePickerAsync(new FilePickerOpenOptions
        {
            Title = "Open Text File",
            AllowMultiple = false,
            SuggestedFileType = new FilePickerFileType("txt")
        });
        return files;
    }

    /// <summary>
    ///
    /// </summary>
    private void ExitMenuItem(object sender, RoutedEventArgs e)
    {
        Close();
    }

    /// <summary>
    /// Generate Labels
    /// </summary>
    private void GenerateLabelsClickEvent(object sender, RoutedEventArgs e)
    {
        char[] startAddress = new char[_lineNumbers[0].Length];
        char[] endAddress = new char[_lineNumbers[_lineNumbers.Count - 1].Length];
        int firstOccurence = 0;
        int lastOccurrence = 0;

        int count = 0;
        foreach (char chr in _lineNumbers[0])
        {
            startAddress[count++] = chr;
        }

        count = 0;
        foreach (char chr in _lineNumbers[_lineNumbers.Count - 1])
        {
            endAddress[count++] = chr;
        }

        // var ms = new MemoryLocationsToConvertSelector(startAddress, endAddress);
        // if (ms.ShowDialog() != DialogResult.OK) return;
        
        // var start = int.Parse(ms.GetSelectedMemStartLocation, System.Globalization.NumberStyles.HexNumber);
        var start = 2048;
        // var end = int.Parse(ms.GetSelectedMemEndLocation, System.Globalization.NumberStyles.HexNumber);
        var end = 4096;
        // //var dataStatmentsRequired = ms.GetConvertIllegalOpCodes;
        
        var delta = end - start;
        var firstIllegalOpcodeFound = false;
        var replacedWithDataStatements = new Dictionary<string, string[]>();
        
        if (start <= end)
        {
            //Check to see if illegal opcodes exist within the code selection
            for (var i = start; i < end; i++)
            {
                if (_illegalOpcodes.Contains(i.ToString("X4")))
                {
                    if (i > firstOccurence && !firstIllegalOpcodeFound)
                    {
                        firstOccurence = i;
                        firstIllegalOpcodeFound = true;
                    }
        
                    if (i > lastOccurrence)
                    {
                        lastOccurrence = i;
                    }
                }
            }
        
            var temp = lastOccurrence.ToString("X4");
            int index = 0;
            foreach (string str in _parser.Code)
            {
                if (str.Contains(temp))
                {
                    // nudge the last Occurrence along to the next valid opCode
                    lastOccurrence = int.Parse(_lineNumbers[++index], System.Globalization.NumberStyles.HexNumber);
                }
        
                index++;
            }
        
            for (int i = firstOccurence; i < lastOccurrence; i++)
            {
                // Replace the Illegal Opcodes with data statement
                if (_dataStatements.TryGetValue(i.ToString("X4"), out string[] dataValue))
                {
                    replacedWithDataStatements.Add(i.ToString("X4"), dataValue);
                }
            }
        
            // var result = DialogResult.No;
            // if (firstIllegalOpcodeFound)
            // {
            //     result = MessageBox.Show(@"Illegal Opcodes found within the selection from : " + firstOccurence.ToString("X4") + @" to " + lastOccurrence.ToString("X4") + "\n"
            //                              + @"Replace Illegal Opcodes with data statements ?", @" ", MessageBoxButtons.YesNo);
            // }
        
            var convertToBytes = false;
            // if (result == DialogResult.Yes)
            // {
            //     convertToBytes = true;
            // }
            // AddLabels(delta, ms.GetSelectedMemStartLocation, ms.GetSelectedMemEndLocation, convertToBytes,
            //     replacedWithDataStatements);
            AddLabels(delta, start.ToString(), end.ToString(), convertToBytes, replacedWithDataStatements);
        }
        else
        {
            //MessageBox.Show(@"The selected end address exceeds the length of the bytes $" + _lineNumbers[_lineNumbers.Count - 1]);
        }
    }

    /// <summary>
    /// Clear Collections
    /// </summary>
    private void ClearCollections()
    {
        ClearLeftWindow();
        ClearRightWindow();
    }

    /// <summary>
    /// Clear Left Window
    /// </summary>
    private void ClearLeftWindow()
    {
        LeftTextBox.Clear();
        _parser.Code.Clear();
        _parser.DataStatements.Clear();
    }

    /// <summary>
    /// Clear Right Window
    /// </summary>
    private void ClearRightWindow()
    {
        _assemblyCreator.PassOne.Clear();
        _assemblyCreator.PassTwo.Clear();
        _assemblyCreator.PassThree.Clear();
        _assemblyCreator.Found.Clear();
        _assemblyCreator.LabelLocations.Clear();
        _assemblyCreator.BranchLocations.Clear();
    }

    /// <summary>
    ///
    /// </summary>
    private void SaveLeftWindowContent(object sender, RoutedEventArgs e)
    {
        Save(_parser.Code, "txt");
    }

    /// <summary>
    ///
    /// </summary>
    private void SaveRightWindowContent(object sender, RoutedEventArgs e)
    {
        Save(_assemblyCreator.PassThree, "txt");
    }

    /// <summary>
    ///
    /// </summary>
    private async void Save(List<string> collection, string filter)
    {
        var saveFileDialog = await SaveFileDialogue(filter);
        if (saveFileDialog != null) await File.WriteAllLinesAsync(saveFileDialog.Path.AbsolutePath, collection);
    }

    /// <summary>
    ///
    /// </summary>
    private async Task<IStorageFile?> SaveFileDialogue(string filter)
    {
        var topLevel = GetTopLevel(this);
        var saveFileDialog = await topLevel.StorageProvider.SaveFilePickerAsync(new FilePickerSaveOptions
        {
            Title = "Save File",
            SuggestedFileType = new FilePickerFileType(filter)
        });
        return saveFileDialog;
    }
    
    /// <summary>
    /// Export Bytes As Binary Menu Item Clicked
    /// </summary>
    private async void ExportBytesAsBinaryMenuItemClicked(object sender, RoutedEventArgs e)
    {
        var start = 0;
        var end = 1984;
        
        // var ms = new MemoryLocationsToConvertSelector(_startAddress, _endAddress);
        // if (ms.ShowDialog() != DialogResult.OK) return;
        
        // var start = int.Parse(ms.GetSelectedMemStartLocation, System.Globalization.NumberStyles.HexNumber) - _userDefinedStartAddress;
        // var end = int.Parse(ms.GetSelectedMemEndLocation, System.Globalization.NumberStyles.HexNumber) - _userDefinedStartAddress;
        
        var saveFileDialog = await SaveFileDialogue("All files (*.*)|*.*|Binary files (*.bin)|*.bin");
        if (saveFileDialog == null) { return; }
        if (_data.Length <= 0 || end > _data.Length) { return; }
        await using var fileStream = new FileStream(saveFileDialog.Path.AbsolutePath, FileMode.Create);
        for (var i = start; i <= end; i++)
        {
            fileStream.WriteByte(_data[i]);
        }
    }
   
    /// <summary>
    /// Export Bytes As Text Menu Item Clicked
    /// </summary>
    private void ExportBytesAsTextMenuItemClicked(object sender, RoutedEventArgs e)
    {
        var start = 0;
        var end = 1984;
        var fileStart = start;
        var fileEnd = end;
        
        var dataStatements = new List<string>
        {
            "*=$" + fileStart.ToString("x4"),
            "; start address:" + fileStart.ToString("x4") + "-" + fileEnd.ToString("x4")
        };
        var eightBytes = "!byte $";
        var byteCounter = 0;

        if (_data.Length > 0 && end <= _data.Length)
        {
            for (var i = start; i <= end; i++)
            {
                if (byteCounter != 8)
                {
                    eightBytes += _data[i].ToString("X2") + ",$";
                    byteCounter++;
                }
                else
                {
                    eightBytes = eightBytes.Remove(eightBytes.LastIndexOf(','), 2);
                    dataStatements.Add(eightBytes);
                    eightBytes = "!byte $";
                    byteCounter = 0;
                }
            }
            Save(dataStatements, "Text files (*.txt)|*.txt");
        }
    }
}