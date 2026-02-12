using Avalonia;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Markup.Xaml;

namespace C64BinaryToAssemblyConverter;

public partial class LoadIntoMemoryLocationSelector : Window
{
    public string? Result { get; private set; }
    
    public LoadIntoMemoryLocationSelector()
    {
        InitializeComponent();
    }
    
    private void OnOkClick(object? sender, RoutedEventArgs e)
    {
        Result = this.FindControl<TextBox>("StartAddressSelector")?.Text;
        Close(Result);
    }

    private void OnCancelClick(object? sender, RoutedEventArgs e)
    {
        Close(null);
    }
}