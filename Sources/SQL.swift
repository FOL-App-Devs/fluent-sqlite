import Fluent

class SQL {

	var table: String
	var operation: Operation

	var filters: [Filter]?
	var limit: Int?
	var data: [String: String]?

	enum Operation {
		case SELECT, DELETE, INSERT, UPDATE
	}

	init(operation: Operation, table: String) {
		self.operation = operation
		self.table = table
	}

	var query: String {
		var query: [String] = []

		switch self.operation {
		case .SELECT:
			query.append("SELECT * FROM")
		case .DELETE:
			query.append("DELETE FROM")
		case .INSERT:
			query.append("INSERT INTO")
		case .UPDATE:
			query.append("UPDATE")
		}
		//UPDATE table_name
// SET column1 = value1, column2 = value2...., columnN = valueN
// WHERE [condition];

		query.append("`\(self.table)`")

		if let data = self.data {

			if self.operation == .INSERT {

				var columns: [String] = []
				var values: [String] = []

				for (key, val) in data {
					columns.append("`\(key)`")

					if val == "NULL" {
						values.append("\(val)")
					} else {
						values.append("'\(val)'")
					}
				}

				let columnsString = columns.joinWithSeparator(", ")
				let valuesString = values.joinWithSeparator(", ")
				query.append("(\(columnsString)) VALUES (\(valuesString))")

			} else if self.operation == .UPDATE {

				for (key, val) in data {
					var updates: [String] = []

					let value: String

					if val == "NULL" {
						value = "\(val)"
					} else {
						value = "'\(val)'"
					}

					updates.append("`\(key)` = \(value)")

					let updatesString = updates.joinWithSeparator(", ")
					query.append("SET \(updatesString)")
				}

			}

		}

		if let filters = self.filters {
			if filters.count > 0 {
				query.append("WHERE")
			}

			for filter in filters {
				if let filter = filter as? CompareFilter {
					query.append(" `\(filter.key)` = '\(filter.value)'")
				}
			}
		}

		if let limit = self.limit {
			query.append("LIMIT \(limit)")
		}

		let queryString = query.joinWithSeparator(" ")

		self.log(queryString)

		return queryString + ";"
	}

	func log(message: Any) {
		print("[SQL] \(message)")
	}
}