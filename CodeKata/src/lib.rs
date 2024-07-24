use pyo3::prelude::*;
use polars::frame::DataFrame;
use polars::io::SerReader;
use polars::prelude::{CsvReadOptions, PolarsResult};
use pyo3_polars::PyDataFrame;
use polars_lazy::prelude::*;

#[pyfunction]
fn get_birthdays(csv_file: &str, date: &str) -> PyResult<PyDataFrame> {
    let df= read_csv(csv_file).unwrap();
    let df2 = get_detail_by_date_of_birth(df, date);
    Ok(PyDataFrame(df2))
}

fn get_detail_by_date_of_birth(data_frame: DataFrame, date: &str) -> DataFrame {
    return data_frame
        .clone()
        .lazy()
        .filter(col("Date of birth").eq(lit(date)))
        .collect()
        .unwrap();

}

fn read_csv(csv_file: &str) -> PolarsResult<DataFrame> {
    CsvReadOptions::default()
        .with_has_header(true)
        .try_into_reader_with_file_path(Some(csv_file.into()))?
        .finish()
}

/// A Python module implemented in Rust. The name of this function must match
/// the `lib.name` setting in the `Cargo.toml`, else Python will not be able to
/// import the module.
#[pymodule]
fn birthday(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(get_birthdays, m)?)?;
    Ok(())
}