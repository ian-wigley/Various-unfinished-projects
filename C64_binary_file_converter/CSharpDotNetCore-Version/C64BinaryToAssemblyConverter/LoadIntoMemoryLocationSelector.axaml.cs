using Avalonia.Controls;
using Avalonia.Interactivity;

namespace C64BinaryToAssemblyConverter;

public partial class LoadIntoMemoryLocationSelector : Window
{
    public LoadIntoMemoryLocationSelector()
    {
        InitializeComponent();
    }

    public string? Result { get; private set; }

    private void OnOkClick(object? sender, RoutedEventArgs e)
    {
        Result = this.FindControl<ComboBox>("StartAddressSelector")?.Text;
        Close(Result);
    }

    private void OnCancelClick(object? sender, RoutedEventArgs e)
    {
        Close(null);
    }
}