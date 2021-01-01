import random
import datetime
from dateutil.relativedelta import *
# Generate example ledger file, for a few years of data.

# Predictable results
random.seed(42)
# Define a small number of accounts

# Assets
savings_name = "Assets:Bank:Savings"
brokerage_name = "Assets:Brokerage"
# Income 
salary_name = "Income:Salary" 
# Expenses
rent_name = "Expenses:Rent"
food_name = "Expenses:Food"

# Ticket symbol
ticker_name = "STOCK"

# Convert annual to monthly rate
def annual_to_monthly(rate):
    return ((rate + 1)**(1/12))

# Starting points for repeating amounts
salary = 50_000 / 12
rent = 1_600
food = 700

savings = 0.0

# Use these constants to maintain a savings account,
# moving data to investments when exceeded.
max_savings = 25_000
min_savings = 10_000

# Inflation and variation
salary_inflation = annual_to_monthly(0.04)
salary_variation = 0.02
rent_inflation = annual_to_monthly(0.03)
rent_variation = 0.02
food_inflation = annual_to_monthly(0.02)
food_variation = 0.2

# Stock prices
min_stock_growth = annual_to_monthly(-0.25)
max_stock_growth = annual_to_monthly(0.4)
stock_price = 10.00
# each month we record a new price by
# selecting a growth rate between min/max,
# and adjusting the stock_price

# Start Date
start_time = datetime.datetime.fromisoformat("2001-01-01")
end_time = datetime.datetime.fromisoformat("2021-01-01")

# Convert annual to monthly rate
def annual_to_monthly(rate):
    return ((rate + 1)**(1/12))

# Return a ledger-formatted transaction
def gen_transaction(txdate, description, postings):
    # Each posting is an (account_name, amount) tuple
    # if the amount is nil, the currency and amount is omitted
    date_str = txdate.strftime("%Y-%m-%d")
    txn_str =  "{} * {}\n".format(date_str,description)
    for (acct, amt) in postings:
        if amt:
            txn_str += "    "+acct+"  "+amt+"\n" 
        else:
            txn_str += "    "+acct+"\n"
    return txn_str

# Every month we will generate income & expenses.
# If savings exceeds threshold, make an investment.
curr_month = start_time
while curr_month < end_time:
    # Update expenses/income based on inflation rates
    salary = salary*salary_inflation
    food = food*food_inflation
    rent = rent*rent_inflation
    # determine actuals for this month w/ variation
    salary_act = round(salary * random.uniform(1, 1+salary_variation), 2)
    food_act = round(food * random.uniform(1, 1+food_variation), 2)
    rent_act = round(rent * random.uniform(1, 1+rent_variation), 2)
    # Estimate current savings after expenses/income
    savings += round(salary_act - food_act - rent_act,2)
    # Update stock price
    # select a random value between min/max stock growth
    stock_adjust = random.uniform(min_stock_growth, max_stock_growth)
    # Just for fun, randomly make a large adjustment
    if (random.random() > 0.98):
        stock_adjust = random.uniform(0.5, 1.3)
    stock_price *= stock_adjust
    # Generate a transaction for salary
    print(gen_transaction(curr_month, "Salary", [(salary_name, "$"+str(-salary_act)), (savings_name, None)]))
    # Food and Rent expenses
    print(gen_transaction(curr_month, "Groceries", [(food_name, "$"+str(food_act)), (savings_name, None)]))
    print(gen_transaction(curr_month, "Rent", [(rent_name, "$"+str(rent_act)), (savings_name, None)]))
    # move money to investment if we exceed threshold in savings
    if savings > max_savings:
        delta = round(savings - min_savings)
        savings = min_savings
        # Convert delta to amount of stock
        shares = round(delta / stock_price, 3)
        print(gen_transaction(curr_month, "Investment", [(brokerage_name, str(shares)+" "+ticker_name), (savings_name, "$"+str(-delta))]))
    # increment month
    curr_month = curr_month + relativedelta(months=+1)


