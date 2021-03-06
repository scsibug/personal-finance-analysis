library(ggplot2)                     # plots
library(ggthemes)                    # fivethirtyeight theme
library(scales)                      # $ in plot axis
library(dplyr, warn.conflicts=FALSE) # left join
library(zoo, warn.conflicts=FALSE)   # rollapply

# Base directory for all generated graphs
gdir = "graphs"
rdir = "reports-generated"
gwidth = 7
gheight = 5 

theme <- theme_fivethirtyeight(base_size=8, base_family="sans")

# Create graph directory if it does not exist
dir.create(file.path(gdir), showWarnings = FALSE)

# Parse ledger report file into dataframe with date & amount.
# Assumes no units, and dates in YYYY-MM-DD format.
std.parse <- function(filename) {
  r <- read.csv(file=filename, header=FALSE, sep=" ",
                col.names=c("date","amount"),stringsAsFactors=FALSE)
  r$dt <- as.Date(as.POSIXct(strptime(r$date, format="%Y-%m-%d"))) 
  r[c("dt","amount")]
}

# Net Worth Plot
cat("* Plotting Net Worth\n")
nw.raw <- std.parse(file.path(rdir, "networth.monthly.csv"))
nw.plot <- ggplot(nw.raw, aes(x=dt, y=amount)) +
  ggtitle("Net Worth") + geom_line() + theme +
  scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA))
ggsave(nw.plot, file=file.path(gdir, "networth.monthly.png"),
       width=gwidth, height=gheight)

# Monthly Expenses
# Expense data, monthly
exp.m <- std.parse(file.path(rdir, "expenses.monthly.csv")) %>%
  rename(expenses = amount) 
cat("* Plotting Monthly Expenses\n")
expenses.monthly.plot <- ggplot(exp.m, aes(x=dt,y=expenses)) +
  ggtitle("Monthly Expenses") + geom_line() + theme +
  scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA))
ggsave(expenses.monthly.plot, file=file.path(gdir, "expenses.monthly.png"),
       width=gwidth, height=gheight)

# Years expenses saved (withdrawal rate calculation)
# Smooth the graph by averaging over several months of data
smooth.months = 4
# Invested assets, monthly totals
inv.m <- std.parse(file.path(rdir, "invested.monthly.csv")) %>%
  rename(assets = amount)
# Join datasets by their common 'dt' attribute
wr <- inv.m %>% left_join(exp.m, by=c("dt"))
# Calculate the rate (annualized expenses / invested asssets)
wr$rate <- ((wr$expenses*12)/wr$assets)
# Rolling mean to smooth data
wr <- wr %>% mutate(rate.mean = rollapply(data=rate, width=smooth.months,
                                          align="right", FUN=mean, fill = NA))
# Generate plot
cat("* Plotting Years of Saved Expenses\n")
years.exp.smooth.plot <- ggplot(wr, aes(x=dt,y=1/rate.mean)) +
  ggtitle("Years of Expenses Saved") + geom_line(na.rm=TRUE) + theme +
  geom_hline(aes(yintercept=25), linetype=2) +
  scale_y_continuous(limits = c(0, NA))
ggsave(years.exp.smooth.plot, file=file.path(gdir, "years.expenses.png"),
  width=gwidth, height=gheight)
