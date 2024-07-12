use pyo3::prelude::*;
use polars::frame::DataFrame;
use polars::io::SerReader;
use polars::prelude::{CsvReadOptions, PolarsResult};
use pyo3_polars::PyDataFrame;
use polars_lazy::prelude::*;

#[pyfunction]
fn get_birthdays() -> PyResult<PyDataFrame> {
    let df= read_csv().unwrap();
    let df2 = get_detail_by_date_of_birth(df, "1973-04-24");
    // wrap the dataframe, and it will be automatically
    // converted to a python polars dataframe
    Ok(PyDataFrame(df2))
}

fn get_detail_by_date_of_birth(data_frame: DataFrame, date: &str) -> DataFrame {
    return data_frame
        .lazy()
        .select(&[col("Name"), col("Email"),
            when(col("Date of birth").eq(lit(date)))
                .then(1).otherwise(2)]).collect().unwrap();

}

fn read_csv() -> PolarsResult<DataFrame> {
    CsvReadOptions::default()
        .with_has_header(true)
        .try_into_reader_with_file_path(Some("birthdays.csv".into()))?
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


// #[cfg(test)]
// mod tests {
//     use super::*;
//
//     // #[test]
//     // fn it_works() {
//     //     let result = adder(2, 2);
//     //     assert_eq!(result, 4);
//     // }
//
//     // #[test]
//     // fn read_scv() {
//     //     let _df = example();
//     // }
//
// }
