# ExpressionParser.gd
class_name ExpressionParser

var tokens = []
var current = 0

func parse(expression: String):
	tokens = tokenize(expression)
	current = 0
	return parse_expression()

func tokenize(expression: String) -> Array:
	var result = []
	var token = ""
	var special_chars = ["(", ")", "<", ">", "=", "!", "+", "-", "*", "/", "&", "|"]
	var compound_operators = ["<=", ">=", "==", "!=", "&&", "||"]

	var i = 0
	while i < expression.length():
		var c = expression[i]
		
		if c in [" ", "\t", "\n"]:
			if token != "":
				result.append(token)
				token = ""
		elif c in special_chars:
			if token != "":
				result.append(token)
				token = ""
			
			# 检查是否是复合运算符
			if i + 1 < expression.length():
				var next_c = expression[i + 1]
				var compound = c + next_c
				if compound in compound_operators:
					result.append(compound)
					i += 1  # 跳过下一个字符
				else:
					result.append(c)
			else:
				result.append(c)
		else:
			token += c
		
		i += 1

	if token != "":
		result.append(token)

	return result

func parse_expression():
	var left = parse_comparison()

	while current < tokens.size() and tokens[current] in ["and", "or", "&&", "||"]:
		var operator = tokens[current]
		current += 1
		var right = parse_comparison()
		# 将 && 映射到 and，将 || 映射到 or
		if operator == "&&":
			operator = "and"
		elif operator == "||":
			operator = "or"
		left = {"type": "logical", "operator": operator, "left": left, "right": right}

	return left

func parse_comparison():
	var left = parse_term()

	while current < tokens.size() and tokens[current] in ["<", ">", "<=", ">=", "==", "!="]:
		var operator = tokens[current]
		current += 1
		var right = parse_term()
		left = {"type": "comparison", "operator": operator, "left": left, "right": right}

	return left

func parse_term():
	var left = parse_factor()

	while current < tokens.size() and tokens[current] in ["+", "-"]:
		var operator = tokens[current]
		current += 1
		var right = parse_factor()
		left = {"type": "arithmetic", "operator": operator, "left": left, "right": right}

	return left

func parse_factor():
	var left = parse_primary()

	while current < tokens.size() and tokens[current] in ["*", "/"]:
		var operator = tokens[current]
		current += 1
		var right = parse_primary()
		left = {"type": "arithmetic", "operator": operator, "left": left, "right": right}

	return left

func parse_primary():
	if tokens[current] == "(":
		current += 1
		var expr = parse_expression()
		current += 1  # consume ")"
		return expr
	elif tokens[current].is_valid_float():
		var value = float(tokens[current])
		current += 1
		return {"type": "literal", "value": value}
	elif tokens[current] in ["true", "false"]:
		var value = tokens[current] == "true"
		current += 1
		return {"type": "boolean", "value": value}
	elif tokens[current].begins_with("\"") and tokens[current].ends_with("\""):
		var value = tokens[current].substr(1, tokens[current].length() - 2)
		current += 1
		return {"type": "string", "value": value}
	else:
		var variable = tokens[current]
		current += 1
		return {"type": "variable", "name": variable}
