import bcrypt
from flask import Flask, jsonify,request
import json
app = Flask(__name__)
@app.route('/regist',methods = ["POST"])
def jsonData():
    # json data
    data = request.get_json()
    userName = data["userName"]
    password = data["password"]
    # เปิด DB
    with open('users.json') as f:
        data = json.load(f)
    for user in data:
        if user.get('name') == userName:
            #! ข้อมูลซ้ำ ส่งออก
            return jsonify({'status':'failure'})
    # อ่านข้อมูลจากไฟล์ users.json
    with open('users.json', 'r') as f:
        data = json.load(f)
    # เพิ่มข้อมูลใหม่ในรูปแบบ dictionary
    new_user = {
        "name": userName,
        "password": password
    }
    # เพิ่มข้อมูลใหม่ลงใน list ของข้อมูลที่อ่านมาจากไฟล์
    data.append(new_user)
    # เขียนข้อมูลกลับลงไฟล์ users.json
    with open('users.json', 'w') as f:
        json.dump(data, f, indent=2)
    #!  ส่งออก
    return jsonify({'status':'success'})


@app.route('/login',methods = ["POST","get"])
def login():
    userName = request.get_json()['userName']
    with open('users.json') as f:
        data = json.load(f)
    for user in data:
        if user.get('name') == userName:
            #!  ส่งออก
            return jsonify({'status':'succsess','hash':user.get('password')})
    #!  ส่งออก
    return jsonify({'status':'failure'})

app.run(debug=True)



# ไม่ได้ใช้
# salt = bcrypt.gensalt()
# password = b'mysecretpassword'
# password_hash1 = bcrypt.hashpw(password, salt)
# password_hash = b"$2a$10$FhRYZElDQWRk0Ght6vrrxuirS72kjnnLkkN5yh7Dspbjxf3URVIaO"
# password_hash = b"$2a$10$swR3ZkbBDcUyGShiHrmSteEgsPG/0ljyB3SkHGGGp7X/NxqevRL.6"

# config = 'password'

# # เช็คว่า password ตรงกับ password hash หรือไม่
# input_password = b'mysecretpassword'
# def hash_password(password):
#     print(isinstance(password,str))
    
#     # if(type(password) == "str"):
#     if(isinstance(password,str)):
#         input_password = password.encode('utf8')
#     else:
#         return ({'type':type(password),'value':password})
#     if bcrypt.checkpw(input_password, password_hash):
#         print('Password is correct')
#         return password_hash.decode('utf8')
#     else:
#         print('incorrect')
# def hash_encode(password):
#     return bcrypt.hashpw(password.encode('utf8'),salt).decode('utf8')

    