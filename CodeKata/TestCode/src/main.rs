use polars::frame::DataFrame;
use polars::io::SerReader;
use polars::prelude::{CsvReadOptions, PolarsResult};
use polars_lazy::prelude::*;

fn get_birthdays() -> DataFrame {
    let df = read_csv().unwrap();
    let df2 = get_detail_by_date_of_birth(df, "1973-04-24");
    df2
}

fn get_detail_by_date_of_birth(data_frame: DataFrame, date: &str) -> DataFrame {
    let a = data_frame
        .lazy()
        .select(&[
            col("Name"),
            col("Email"),
            when(col("Date of birth").eq(lit(date)))
                .then(1)
                .otherwise(2),
        ])
        .collect()
        .unwrap();

    return a;

    // return data_frame
    //     .lazy()
    //     .select(&[col("Name"), col("Email"),
    //         when(col("Date of birth").eq(lit(date)))
    //             .then(1).otherwise(2)]).collect().unwrap();
}

fn read_csv() -> PolarsResult<DataFrame> {
    CsvReadOptions::default()
        .with_has_header(true)
        .try_into_reader_with_file_path(Some("assets/birthdays.csv".into()))?
        .finish()
}

fn main() {
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_birthdays() {
        let result = get_birthdays();
        assert_eq!(result.shape(), (100,3));
    }

    #[test]
    fn test_read_scv() {
        let result = read_csv();
        _ = result;
    }

    #[test]
    fn test_get_detail_by_date_of_birth() {
        let df = read_csv().unwrap();
        let result = get_detail_by_date_of_birth(df, "1973-04-24");
        assert_eq!(result.shape(), (100,3));
    }
}
