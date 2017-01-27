"""Fibonacci program

- Reads in an integer and prints the corresponding Fibonacci number.
- Uses the naive recursion strategy.
"""
def fibonacci(num):
	if num == 0 or num == 1:
		return num
	else:
		return fibonacci(num - 1) + fibonacci(num - 2)


def main():
	number = int(input("Please input a number: "))
	result = fibonacci(number)
	print(result)


if __name__ == "__main__":
	main()