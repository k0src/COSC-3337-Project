using DataFrames
using CairoMakie

const DISTCAT_COLORS = [
  :steelblue, :orangered, :seagreen, :goldenrod, :mediumpurple,
  :deeppink, :darkcyan, :coral, :slateblue, :olivedrab,
]

# Data

function distcat_get_group_reason_start(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_start, 'unknown') AS reason_start,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY reason_start
    ORDER BY count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_user_reason_start(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_start, 'unknown') AS reason_start,
      COUNT(*) AS count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY reason_start
    ORDER BY count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_group_reason_end(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_end, 'unknown') AS reason_end,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY reason_end
    ORDER BY count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_user_reason_end(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_end, 'unknown') AS reason_end,
      COUNT(*) AS count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY reason_end
    ORDER BY count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_group_bool_flags(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      SUM(CASE WHEN shuffle THEN 1 ELSE 0 END)  AS shuffle_true,
      SUM(CASE WHEN NOT shuffle THEN 1 ELSE 0 END) AS shuffle_false,
      SUM(CASE WHEN skipped THEN 1 ELSE 0 END)  AS skipped_true,
      SUM(CASE WHEN NOT skipped THEN 1 ELSE 0 END) AS skipped_false,
      SUM(CASE WHEN offline THEN 1 ELSE 0 END)  AS offline_true,
      SUM(CASE WHEN NOT offline THEN 1 ELSE 0 END) AS offline_false,
      COUNT(*) AS total
    FROM listening_history
    $year_filter
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_user_bool_flags(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      SUM(CASE WHEN shuffle THEN 1 ELSE 0 END)  AS shuffle_true,
      SUM(CASE WHEN NOT shuffle THEN 1 ELSE 0 END) AS shuffle_false,
      SUM(CASE WHEN skipped THEN 1 ELSE 0 END)  AS skipped_true,
      SUM(CASE WHEN NOT skipped THEN 1 ELSE 0 END) AS skipped_false,
      SUM(CASE WHEN offline THEN 1 ELSE 0 END)  AS offline_true,
      SUM(CASE WHEN NOT offline THEN 1 ELSE 0 END) AS offline_false,
      COUNT(*) AS total
    FROM listening_history
    $year_filter
    GROUP BY username
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_group_skip_by_shuffle(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      shuffle::TEXT AS shuffle,
      skipped::TEXT AS skipped,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY shuffle, skipped
    ORDER BY shuffle, skipped
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_user_skip_by_shuffle(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      shuffle::TEXT AS shuffle,
      skipped::TEXT AS skipped,
      COUNT(*) AS count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY shuffle, skipped
    ORDER BY shuffle, skipped
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_group_completion_by_reason_start(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_start, 'unknown') AS reason_start,
      skipped::TEXT AS skipped,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY reason_start, skipped
    ORDER BY reason_start, skipped
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function distcat_get_user_completion_by_reason_start(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      COALESCE(reason_start, 'unknown') AS reason_start,
      skipped::TEXT AS skipped,
      COUNT(*) AS count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY reason_start, skipped
    ORDER BY reason_start, skipped
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_reason_proportions_group(df, col, title_str, fname, suffix)
  nrow(df) == 0 && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  total = sum(df.count)
  total == 0 && return
  categories = String.(coalesce.(df[!, col], "unknown"))
  proportions = Float64.(df.count) ./ total
  n = length(categories)
  colors = [DISTCAT_COLORS[mod1(i, length(DISTCAT_COLORS))] for i in 1:n]
  fig = Figure(size=(900, 500))
  ax = Axis(fig[1, 1],
    title="$title_str - Group - $title_label",
    ylabel="Proportion",
    xticks=(1:n, categories),
    xticklabelrotation=π / 4
  )
  barplot!(ax, 1:n, proportions, color=colors)
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_reason_proportions_users(user_dfs, col, names, title_str, fname, suffix)
  if all(nrow(df) == 0 for df in values(user_dfs))
    return
  end
  title_label = suffix == "alltime" ? "All-Time" : suffix

  all_cats = String[]
  for df in values(user_dfs)
    nrow(df) == 0 && continue
    append!(all_cats, String.(coalesce.(df[!, col], "unknown")))
  end
  unique_cats = sort(unique(all_cats))
  isempty(unique_cats) && return

  user_keys = collect(keys(user_dfs))
  n_users = length(user_keys)
  n_cats = length(unique_cats)

  x_pos = Int[]
  y_vals = Float64[]
  stk = Int[]

  for (ui, uk) in enumerate(user_keys)
    df = user_dfs[uk]
    total = nrow(df) == 0 ? 0 : sum(df.count)
    total == 0 && continue
    cat_counts = Dict(
      String(coalesce(r[col], "unknown")) => Int(r.count) for r in eachrow(df)
    )
    for (ci, cat) in enumerate(unique_cats)
      push!(x_pos, ui)
      push!(y_vals, get(cat_counts, cat, 0) / total)
      push!(stk, ci)
    end
  end

  isempty(x_pos) && return

  colors = [DISTCAT_COLORS[mod1(s, length(DISTCAT_COLORS))] for s in stk]

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="$title_str - Per User - $title_label",
    ylabel="Proportion",
    xticks=(1:n_users, [get(names, uk, uk) for uk in user_keys])
  )
  barplot!(ax, x_pos, y_vals; stack=stk, color=colors)
  elems = [PolyElement(polycolor=DISTCAT_COLORS[mod1(i, length(DISTCAT_COLORS))]) for i in 1:n_cats]
  Legend(fig[1, 2], elems, unique_cats, "Category")
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_bool_flags_group(flags_df, suffix)
  nrow(flags_df) == 0 && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  row = first(flags_df)
  total = Int(row.total)
  total == 0 && return
  rates = [
    row.shuffle_true / total,
    row.skipped_true / total,
    row.offline_true / total,
  ]
  fig = Figure(size=(600, 500))
  ax = Axis(fig[1, 1],
    title="Shuffle, Skipped, Offline - Group - $title_label",
    ylabel="Rate",
    xticks=(1:3, ["Shuffle", "Skipped", "Offline"])
  )
  barplot!(ax, 1:3, rates, color=[:steelblue, :orangered, :seagreen])
  fname = "bool_flags_group_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_bool_flags_users(user_flags_df, names, suffix)
  nrow(user_flags_df) == 0 && return
  title_label = suffix == "alltime" ? "All-Time" : suffix

  user_keys = String.(user_flags_df.username)
  n_users = length(user_keys)
  flag_colors = [:steelblue, :orangered, :seagreen]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, row) in enumerate(eachrow(user_flags_df))
    total = Int(row.total)
    total == 0 && continue
    push!(x_pos, ui)
    push!(y_vals, row.shuffle_true / total)
    push!(dodge_idxs, 1)
    push!(x_pos, ui)
    push!(y_vals, row.skipped_true / total)
    push!(dodge_idxs, 2)
    push!(x_pos, ui)
    push!(y_vals, row.offline_true / total)
    push!(dodge_idxs, 3)
  end

  isempty(x_pos) && return

  display_labels = [get(names, String(row.username), String(row.username)) for row in eachrow(user_flags_df)]

  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Shuffle, Skipped, Offline - Per User - $title_label",
    ylabel="Rate",
    xticks=(1:n_users, display_labels)
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[flag_colors[d] for d in dodge_idxs])
  elems = [PolyElement(polycolor=flag_colors[i]) for i in 1:3]
  Legend(fig[1, 2], elems, ["Shuffle", "Skipped", "Offline"], "Flag")
  fname = "bool_flags_users_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_skip_by_shuffle_group(df, suffix)
  nrow(df) == 0 && return
  title_label = suffix == "alltime" ? "All-Time" : suffix

  shuffle_vals = sort(unique(String.(coalesce.(df.shuffle, "null"))))

  x_pos = Int[]
  y_vals = Float64[]
  stk = Int[]

  for (xi, shuf) in enumerate(shuffle_vals)
    relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                for r in eachrow(df) if String(coalesce(r.shuffle, "null")) == shuf]
    total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
    total == 0 && continue
    skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
    push!(x_pos, xi)
    push!(y_vals, (total - skipped_n) / total)
    push!(stk, 1)
    push!(x_pos, xi)
    push!(y_vals, skipped_n / total)
    push!(stk, 2)
  end

  isempty(x_pos) && return

  fig = Figure(size=(700, 500))
  ax = Axis(fig[1, 1],
    title="Skip Rate by Shuffle - Group - $title_label",
    ylabel="Proportion",
    xticks=(1:length(shuffle_vals), ["Shuffle: $s" for s in shuffle_vals])
  )
  barplot!(ax, x_pos, y_vals;
    stack=stk,
    color=[s == 1 ? :steelblue : :orangered for s in stk]
  )
  elems = [PolyElement(polycolor=:steelblue), PolyElement(polycolor=:orangered)]
  Legend(fig[1, 2], elems, ["Completed", "Skipped"])
  fname = "skip_by_shuffle_group_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_skip_by_shuffle_users(user_dfs, names, suffix)
  if all(nrow(df) == 0 for df in values(user_dfs))
    return
  end
  title_label = suffix == "alltime" ? "All-Time" : suffix

  user_keys = collect(keys(user_dfs))
  n_users = length(user_keys)
  shuffle_order = ["true", "false"]
  shuffle_colors = [:steelblue, :orangered]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, uk) in enumerate(user_keys)
    df = user_dfs[uk]
    nrow(df) == 0 && continue
    for (di, shuf) in enumerate(shuffle_order)
      relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                  for r in eachrow(df) if String(coalesce(r.shuffle, "null")) == shuf]
      total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
      total == 0 && continue
      skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
      push!(x_pos, ui)
      push!(y_vals, skipped_n / total)
      push!(dodge_idxs, di)
    end
  end

  isempty(x_pos) && return

  display_labels = [get(names, uk, uk) for uk in user_keys]

  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Skip Rate by Shuffle - Per User - $title_label",
    ylabel="Skip Rate",
    xticks=(1:n_users, display_labels)
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[shuffle_colors[d] for d in dodge_idxs])
  elems = [PolyElement(polycolor=shuffle_colors[i]) for i in 1:2]
  Legend(fig[1, 2], elems, ["Shuffle On", "Shuffle Off"], "Shuffle")
  fname = "skip_by_shuffle_users_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_completion_by_reason_group(df, suffix)
  nrow(df) == 0 && return
  title_label = suffix == "alltime" ? "All-Time" : suffix

  unique_reasons = sort(unique(String.(coalesce.(df.reason_start, "unknown"))))
  n = length(unique_reasons)

  x_pos = Int[]
  y_vals = Float64[]
  stk = Int[]

  for (xi, reason) in enumerate(unique_reasons)
    relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                for r in eachrow(df) if String(coalesce(r.reason_start, "unknown")) == reason]
    total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
    total == 0 && continue
    skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
    push!(x_pos, xi)
    push!(y_vals, (total - skipped_n) / total)
    push!(stk, 1)
    push!(x_pos, xi)
    push!(y_vals, skipped_n / total)
    push!(stk, 2)
  end

  isempty(x_pos) && return

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Completion by reason_start - Group - $title_label",
    ylabel="Proportion",
    xticks=(1:n, unique_reasons),
    xticklabelrotation=π / 4
  )
  barplot!(ax, x_pos, y_vals;
    stack=stk,
    color=[s == 1 ? :steelblue : :orangered for s in stk]
  )
  elems = [PolyElement(polycolor=:steelblue), PolyElement(polycolor=:orangered)]
  Legend(fig[1, 2], elems, ["Completed", "Skipped"])
  fname = "completion_by_reason_group_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_completion_by_reason_users(user_dfs, names, suffix)
  if all(nrow(df) == 0 for df in values(user_dfs))
    return
  end
  title_label = suffix == "alltime" ? "All-Time" : suffix

  all_reasons = String[]
  for df in values(user_dfs)
    nrow(df) == 0 && continue
    append!(all_reasons, String.(coalesce.(df.reason_start, "unknown")))
  end
  unique_reasons = sort(unique(all_reasons))
  isempty(unique_reasons) && return

  user_keys = collect(keys(user_dfs))
  n_users = length(user_keys)
  n_reasons = length(unique_reasons)
  user_colors = [DISTCAT_COLORS[mod1(i, length(DISTCAT_COLORS))] for i in 1:n_users]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (xi, reason) in enumerate(unique_reasons)
    for (ui, uk) in enumerate(user_keys)
      df = user_dfs[uk]
      nrow(df) == 0 && continue
      relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                  for r in eachrow(df) if String(coalesce(r.reason_start, "unknown")) == reason]
      total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
      total == 0 && continue
      skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
      push!(x_pos, xi)
      push!(y_vals, (total - skipped_n) / total)
      push!(dodge_idxs, ui)
    end
  end

  isempty(x_pos) && return

  display_labels = [get(names, uk, uk) for uk in user_keys]

  fig = Figure(size=(1100, 600))
  ax = Axis(fig[1, 1],
    title="Track Completion by reason_start - Per User - $title_label",
    ylabel="Completion Rate",
    xticks=(1:n_reasons, unique_reasons),
    xticklabelrotation=π / 4
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[user_colors[d] for d in dodge_idxs])
  elems = [PolyElement(polycolor=user_colors[i]) for i in 1:n_users]
  Legend(fig[1, 2], elems, display_labels, "User")
  fname = "completion_by_reason_users_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function run_distributions_categorical(names; year=nothing)
  println("\nCalculating...")

  year_label = year === nothing ? "alltime" : string(year)
  title_label = year === nothing ? "All-Time" : string(year)
  no_data(name) = println("No data for $name - $title_label")

  g_reason_start = distcat_get_group_reason_start(year=year)
  g_reason_end = distcat_get_group_reason_end(year=year)
  g_bool = distcat_get_group_bool_flags(year=year)
  g_skip_by_shuffle = distcat_get_group_skip_by_shuffle(year=year)
  g_completion = distcat_get_group_completion_by_reason_start(year=year)

  u_reason_start = Dict(u => distcat_get_user_reason_start(u, year=year) for u in keys(names))
  u_reason_end = Dict(u => distcat_get_user_reason_end(u, year=year) for u in keys(names))
  u_bool = distcat_get_user_bool_flags(year=year)
  u_skip_by_shuffle = Dict(u => distcat_get_user_skip_by_shuffle(u, year=year) for u in keys(names))
  u_completion = Dict(u => distcat_get_user_completion_by_reason_start(u, year=year) for u in keys(names))

  if nrow(g_reason_start) == 0
    println("No group data for $title_label")
    return
  end

  # Print

  println("\nGroup - $title_label\n")

  println("reason_start:")
  total_rs = sum(g_reason_start.count)
  for row in eachrow(g_reason_start)
    n = Int(row.count)
    pct = round(n / total_rs * 100; digits=2)
    println("  $(row.reason_start): $n ($pct%)")
  end

  println("\nreason_end:")
  total_re = sum(g_reason_end.count)
  for row in eachrow(g_reason_end)
    n = Int(row.count)
    pct = round(n / total_re * 100; digits=2)
    println("  $(row.reason_end): $n ($pct%)")
  end

  if nrow(g_bool) > 0
    gb = first(g_bool)
    total = Int(gb.total)

    println("\nshuffle:")
    println("  true: $(Int(gb.shuffle_true)) ($(round(gb.shuffle_true / total * 100; digits=2))%)")
    println("  false: $(Int(gb.shuffle_false)) ($(round(gb.shuffle_false / total * 100; digits=2))%)")

    println("\nskipped:")
    println("  true: $(Int(gb.skipped_true)) ($(round(gb.skipped_true / total * 100; digits=2))%)")
    println("  false: $(Int(gb.skipped_false)) ($(round(gb.skipped_false / total * 100; digits=2))%)")

    println("\noffline:")
    println("  true: $(Int(gb.offline_true)) ($(round(gb.offline_true / total * 100; digits=2))%)")
    println("  false: $(Int(gb.offline_false)) ($(round(gb.offline_false / total * 100; digits=2))%)")
  end

  println("\nskip_by_shuffle:")
  total_sbs = sum(g_skip_by_shuffle.count)
  for row in eachrow(g_skip_by_shuffle)
    n = Int(row.count)
    pct = round(n / total_sbs * 100; digits=2)
    println("  shuffle=$(row.shuffle), skipped=$(row.skipped): $n ($pct%)")
  end

  println("\ncompletion_by_reason_start:")
  total_cbr = sum(g_completion.count)
  for row in eachrow(g_completion)
    n = Int(row.count)
    pct = round(n / total_cbr * 100; digits=2)
    println("  reason_start=$(row.reason_start), skipped=$(row.skipped): $n ($pct%)")
  end

  println("\nPer User - $title_label")

  for (username, display_name) in names
    println("\n$display_name:")

    rs = u_reason_start[username]
    re = u_reason_end[username]
    sbs = u_skip_by_shuffle[username]
    comp = u_completion[username]

    if nrow(rs) == 0
      no_data(display_name)
      continue
    end

    println("  reason_start:")
    total_u_rs = sum(rs.count)
    for row in eachrow(rs)
      n = Int(row.count)
      pct = round(n / total_u_rs * 100; digits=2)
      println("    $(row.reason_start): $n ($pct%)")
    end

    println("\n  reason_end:")
    total_u_re = sum(re.count)
    for row in eachrow(re)
      n = Int(row.count)
      pct = round(n / total_u_re * 100; digits=2)
      println("    $(row.reason_end): $n ($pct%)")
    end

    u_bool_row = filter(r -> String(r.username) == username, u_bool)
    if nrow(u_bool_row) > 0
      ub = first(u_bool_row)
      total_u = Int(ub.total)

      println("\n  shuffle:")
      println("    true: $(Int(ub.shuffle_true)) ($(round(ub.shuffle_true / total_u * 100; digits=2))%)")
      println("    false: $(Int(ub.shuffle_false)) ($(round(ub.shuffle_false / total_u * 100; digits=2))%)")

      println("\n  skipped:")
      println("    true: $(Int(ub.skipped_true)) ($(round(ub.skipped_true / total_u * 100; digits=2))%)")
      println("    false: $(Int(ub.skipped_false)) ($(round(ub.skipped_false / total_u * 100; digits=2))%)")

      println("\n  offline:")
      println("    true: $(Int(ub.offline_true)) ($(round(ub.offline_true / total_u * 100; digits=2))%)")
      println("    false: $(Int(ub.offline_false)) ($(round(ub.offline_false / total_u * 100; digits=2))%)")
    end

    println("\n  skip_by_shuffle:")
    total_u_sbs = sum(sbs.count)
    for row in eachrow(sbs)
      n = Int(row.count)
      pct = round(n / total_u_sbs * 100; digits=2)
      println("    shuffle=$(row.shuffle), skipped=$(row.skipped): $n ($pct%)")
    end

    println("\n  completion_by_reason_start:")
    total_u_cbr = sum(comp.count)
    for row in eachrow(comp)
      n = Int(row.count)
      pct = round(n / total_u_cbr * 100; digits=2)
      println("    reason_start=$(row.reason_start), skipped=$(row.skipped): $n ($pct%)")
    end
  end

  # Plots

  println("\nGenerating plots...")

  plot_reason_proportions_group(
    g_reason_start, :reason_start,
    "reason_start", "reason_start_group_$year_label.png", year_label
  )
  plot_reason_proportions_group(
    g_reason_end, :reason_end,
    "reason_end", "reason_end_group_$year_label.png", year_label
  )

  plot_reason_proportions_users(
    u_reason_start, :reason_start, names,
    "reason_start", "reason_start_users_$year_label.png", year_label
  )
  plot_reason_proportions_users(
    u_reason_end, :reason_end, names,
    "reason_end", "reason_end_users_$year_label.png", year_label
  )

  plot_bool_flags_group(g_bool, year_label)
  plot_bool_flags_users(u_bool, names, year_label)

  plot_skip_by_shuffle_group(g_skip_by_shuffle, year_label)
  plot_skip_by_shuffle_users(u_skip_by_shuffle, names, year_label)

  plot_completion_by_reason_group(g_completion, year_label)
  plot_completion_by_reason_users(u_completion, names, year_label)

  # Save JSON

  println("\nSaving JSON...")

  reason_to_labeled(df, col) = [
    Dict{String,Any}(
      "category" => String(coalesce(r[col], "unknown")),
      "count" => Int(r.count),
    )
    for r in eachrow(df)
  ]

  bool_flags_to_dict(row) = Dict{String,Any}(
    "shuffle_true" => Int(row.shuffle_true),
    "shuffle_false" => Int(row.shuffle_false),
    "shuffle_rate" => row.shuffle_true / row.total,
    "skipped_true" => Int(row.skipped_true),
    "skipped_false" => Int(row.skipped_false),
    "skip_rate" => row.skipped_true / row.total,
    "offline_true" => Int(row.offline_true),
    "offline_false" => Int(row.offline_false),
    "offline_rate" => row.offline_true / row.total,
    "total" => Int(row.total),
  )

  cross_to_labeled(df, col_a, col_b) = [
    Dict{String,Any}(
      col_a => String(coalesce(r[col_a], "null")),
      col_b => String(coalesce(r[col_b], "null")),
      "count" => Int(r.count),
    )
    for r in eachrow(df)
  ]

  gb = nrow(g_bool) > 0 ? bool_flags_to_dict(first(g_bool)) : Dict{String,Any}()

  data = Dict{String,Any}(
    "group" => Dict{String,Any}(
      "reason_start" => reason_to_labeled(g_reason_start, :reason_start),
      "reason_end" => reason_to_labeled(g_reason_end, :reason_end),
      "bool_flags" => gb,
      "skip_by_shuffle" => cross_to_labeled(g_skip_by_shuffle, "shuffle", "skipped"),
      "completion_by_reason_start" => cross_to_labeled(g_completion, "reason_start", "skipped"),
    ),
    "users" => Dict{String,Any}(
      display_name => begin
        rs = u_reason_start[username]
        re = u_reason_end[username]
        sbs = u_skip_by_shuffle[username]
        comp = u_completion[username]
        u_bool_row = filter(r -> String(r.username) == username, u_bool)
        ub = nrow(u_bool_row) > 0 ? bool_flags_to_dict(first(u_bool_row)) : Dict{String,Any}()
        Dict{String,Any}(
          "reason_start" => reason_to_labeled(rs, :reason_start),
          "reason_end" => reason_to_labeled(re, :reason_end),
          "bool_flags" => ub,
          "skip_by_shuffle" => cross_to_labeled(sbs, "shuffle", "skipped"),
          "completion_by_reason_start" => cross_to_labeled(comp, "reason_start", "skipped"),
        )
      end
      for (username, display_name) in names
    ),
  )

  save_json("distributions_categorical_$year_label.json", data)
end

function distributions_categorical(names)
  println("ALL-TIME CATEGORICAL DISTRIBUTIONS")
  run_distributions_categorical(names)

  println("\nPER-YEAR CATEGORICAL DISTRIBUTIONS")
  for year in 2015:2026
    println("\nYear: $year")
    run_distributions_categorical(names, year=year)
  end
end
