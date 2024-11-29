# ExpressionEvaluator.gd

class_name ExpressionEvaluator

var variables = {}

func evaluate(ast):
	match ast["type"]:
		"logical":
			var left = evaluate(ast["left"])
			var right = evaluate(ast["right"])
			match ast["operator"]:
				"and": return left and right
				"or": return left or right
		"comparison":
			var left = evaluate(ast["left"])
			var right = evaluate(ast["right"])
			match ast["operator"]:
				"<": return left < right
				">": return left > right
				"<=": return left <= right
				">=": return left >= right
				"==": return left == right
				"!=": return left != right
		"arithmetic":
			var left = evaluate(ast["left"])
			var right = evaluate(ast["right"])
			match ast["operator"]:
				"+": return left + right
				"-": return left - right
				"*": return left * right
				"/": return left / right
		"literal":
			return ast["value"]
		"variable":
			return variables.get(ast["name"], false)  # 返回 false 如果变量不存在
		"boolean":
			return ast["value"]  # 直接返回布尔值
		"string":
			return ast["value"]  # 直接返回字符串值

func set_variable(name: String, value):
	variables[name] = value

func get_variable(name: String):
	return variables.get(name, null)
