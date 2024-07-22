use polars::export::chrono::NaiveDate;
use polars::frame::DataFrame;
use polars::io::SerReader;
use polars::prelude::{CsvReadOptions, PolarsResult};
use polars_lazy::prelude::*;

fn get_birthdays(csv_file: &str, date: &str) -> DataFrame {
    let df= read_csv(csv_file).unwrap();
    let df2 = get_detail_by_date_of_birth(df, date);
    df2
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_birthdays() {
        let result = get_birthdays("assets/birthdays.csv", "1973-04-24");
        assert_eq!(result.shape(), (1, 3));
    }

    #[test]
    fn test_read_scv() {
        let result = read_csv("assets/birthdays.csv").unwrap();
        assert_eq!(result.shape(), (100, 3));
    }

    #[test]
    fn test_get_detail_by_date_of_birth() {
        let df = read_csv("assets/birthdays.csv").unwrap();
        let date = "1990-03-28";
        let date_only = NaiveDate::parse_from_str(date, "%Y-%m-%d")
            .unwrap();
        println!("{}", date_only);
        let result = get_detail_by_date_of_birth(df, date);
        println!("{}", result);
        assert_eq!(result.shape(), (1, 3));
    }
}
