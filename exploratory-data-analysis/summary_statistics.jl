function summary_statistics()
  conn = get_connection()
  result = execute(conn, "SELECT COUNT(*) FROM listening_history")
  row_count = first(result)[1]
  close(conn)
  println("row count: $row_count")
end
