from flask import Flask

app = Flask(__name__)

@app.route("/sort/<numbers>")
def sort(numbers: str) -> str:
    try:
        numbers = list(map(int, numbers.split(',')))
        return quick_sort(numbers)
    except Exception:
        return "An error occurred"

def quick_sort(nums: list) -> list:
    if len(nums) <= 1:
        return nums
    
    pivot = nums[len(nums) // 2]
    left = [x for x in nums if x < pivot]
    middle = [x for x in nums if x == pivot]
    right = [x for x in nums if x > pivot]

    return quick_sort(left) + middle + quick_sort(right)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
