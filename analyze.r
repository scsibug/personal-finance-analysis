library(ggplot2)
library(ggthemes)
library(scales)
library(dplyr) # left join
library(zoo) # rollapply

# Base directory for all generated graphs
gdir = "graphs"
rdir = "reports-generated"
gwidth = 10
gheight = 7

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
nw.raw <- std.parse(file.path(rdir, "networth.monthly.csv"))
nw.plot <- ggplot(nw.raw, aes(x=dt, y=amount)) +
  ggtitle("Net Worth") + geom_line() +
  theme_fivethirtyeight(base_size=12, base_family="sans") +
  scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA))
ggsave(nw.plot, file=file.path(gdir, "networth.monthly.png"),
       width=gwidth, height=gheight)

# Years expenses saved (withdrawal rate calculation)
# Smooth the graph by averaging over several months of data
smooth.months = 4
# Expense data, monthly
exp.m <- std.parse(file.path(rdir, "expenses.monthly.csv")) %>%
  rename(expenses = amount)
# Invested assets, monthly totals
inv.m <- std.parse(file.path(rdir, "invested.monthly.csv")) %>%
  rename(assets = amount)
# Join datasets by their common 'dt' attribute
wr <- inv.m %>% left_join(exp.m)
# Calculate the rate (annualized expenses / invested asssets)
wr$rate <- ((wr$expenses*12)/wr$assets)
# Rolling mean to smooth data
wr <- wr %>% mutate(rate.mean = rollapply(data=rate, width=smooth.months,
                                          align="right", FUN=mean, fill = NA))
years.exp.smooth.plot <- ggplot(wr, aes(x=dt,y=1/rate.mean)) +
  ggtitle("Years of Expenses Saved") + geom_line() +
  geom_hline(aes(yintercept=25), linetype=2) +
  theme_fivethirtyeight(base_size=12, base_family="sans") +
  scale_y_continuous(limits = c(0, NA))
ggsave(years.exp.smooth.plot, file=file.path(gdir, "years.expenses2.png"),
  width=gwidth, height=gheight)
