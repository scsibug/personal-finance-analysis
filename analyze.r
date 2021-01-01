library(ggplot2)
library(ggthemes)
library(scales)

# Base directory for all generated graphs
gdir = "graphs"
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
nw.raw <- std.parse("reports-generated/networth.monthly.csv")
nw.plot <- ggplot(nw.raw, aes(x=dt, y=amount)) +
  ggtitle("Net Worth") + geom_line() +
  theme_fivethirtyeight(base_size=12, base_family="sans") +
  scale_y_continuous(labels = scales::dollar_format(), limits = c(0, NA))
ggsave(nw.plot, file=file.path(gdir, "networth.monthly.png"),
       width=gwidth, height=gheight)


