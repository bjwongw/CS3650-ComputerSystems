"""A simple calculator

- First, read in the operator as a string.
- Then call one of four function (+, -, /, or *) as appropriate.
- Each function reads in two integers.
- Return the result of the calculation.
- Print the answer and exit.
"""
def add(first_num, second_num):
	"""Adds the first number to the second number"""
	return first_num + second_num


def subtract(first_num, second_num):
	"""Subtracts the second number from the first number"""
	return first_num - second_num


def multiply(first_num, second_num):
	"""Multiplies the first number by the second number"""
	return first_num * second_num


def divide(first_num, second_num):
	if second_num == 0:
		raise ValueError("Cannot divide a number by 0")
	else:
		return first_num / second_num


operations = {
	"+": add, 
	"-": subtract, 
	"*": multiply, 
	"/": divide
}


def simple_calculator(operator, first_num, second_num):
	"""Apply the given operator to the two given numbers

	Args:
		operator: One of the four basic operators: +, -, *, /
		first_num: The first operand
		second_num: The second operand

	Returns:
		The result of the calculation
	"""
	return operations[operator](first_num, second_num)


def main():
	operator = input("Select operation (+, -, *, or /): ")
	first_num = int(input("First number: "))
	second_num = int(input("Second number: "))
	result = simple_calculator(operator, first_num, second_num)
	print(result)


if __name__ == "__main__":
	main()