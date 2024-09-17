from fastapi import FastAPI, HTTPException, BackgroundTasks, Path
import secrets
import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi.middleware.cors import CORSMiddleware
import MySQLdb
from pydantic import BaseModel
import bcrypt
import numpy as np
from sklearn.linear_model import LinearRegression
import pickle
import uvicorn
from datetime import datetime, timedelta

db_config = {
    'host': 'localhost',
    'user': 'root',
    'passwd': '',
    'db': 'ums',
}


class User(BaseModel):
    username: str
    password: str
    email: str
    role: str
    otp: int


conn = MySQLdb.connect(**db_config)
app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)


# OTP related...
async def remove_otp(email: str):
    await asyncio.sleep(300)  # Remove OTP after 5 minutes
    if email in otp_map:
        del otp_map[email]


otp_map = {}


def send_email(subject, message, to_email):
    try:
        # Set up the email server
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()

        # Replace 'YOUR_EMAIL_USERNAME' and 'YOUR_EMAIL_PASSWORD' with your actual email credentials
        email_username = '1901029@iot.bdu.ac.bd'
        email_password = 'ohvgfbujrmliuepi'

        server.login(email_username, email_password)

        # Create message
        msg = MIMEMultipart()
        msg['From'] = email_username
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))

        # Send the email
        server.sendmail(email_username, to_email, msg.as_string())
        print("Email sent successfully!")
    except smtplib.SMTPException as e:
        print(f"Failed to send email: {e}")
    finally:
        server.quit()


@app.post("/generate_otp/")
async def generate_otp(email: str):
    print(f"Received email: {email}")
    if '@' not in email or '.' not in email:
        raise HTTPException(status_code=400, detail="Invalid email format")

    otp = str(secrets.randbelow(900000) + 100000)  # Generate a 6-digit OTP
    otp_map[email] = otp
    asyncio.create_task(remove_otp(email))
    send_email("User Verification", f"Your OTP is: {otp}", email)
    print(f"OTP for {email} is: {otp}")
    cursor = conn.cursor()
    query = "UPDATE otp SET otp=%s, createAt=CURRENT_TIMESTAMP WHERE email=%s"
    cursor.execute(query, (otp, email))
    affectedRows = cursor.rowcount
    if affectedRows == 0:
        query = "INSERT INTO otp(email, otp) VALUES (%s, %s)"
        cursor.execute(query, (email, otp))
    conn.commit()
    cursor.close()

    return {"message": "OTP generated successfully."}


# ...OTP related

# User related...
@app.options("/users/")
async def options_users():
    return {"allow": "GET, POST, PUT, DELETE, OPTIONS"}


@app.post("/users/")
def create_user(user: User):
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()

    print(user)
    query = "SELECT otp FROM otp WHERE email=%s"
    cursor.execute(query, (user.email,))
    row = cursor.fetchone()
    prevOtp = row[0]
    print(f'prevOtp: {prevOtp}')

    msg = ''
    status = ''
    if prevOtp == user.otp:
        print("OTP matched")
        query = "INSERT INTO users (username, password, email, role) VALUES (%s, %s, %s, %s)"
        cursor.execute(query, (user.username, hashed_password, user.email, user.role))
        status = 200
        msg = "User created successfully"
    else:
        print("OTP not matched")
        status = 403
        msg = "Otp not matched"

    print(f'msg: {msg}')
    print(f'status: {status}')

    conn.commit()
    cursor.close()
    return {
        'status': status,
        'msg': msg
    }


# ...User related
class Login(BaseModel):
    username: str
    password: str


@app.post("/login/")
async def login(user: Login):
    conn = MySQLdb.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("SELECT password FROM users WHERE username = %s", (user.username,))
    db_user = cursor.fetchone()
    cursor.close()
    conn.close()
    if db_user and bcrypt.checkpw(user.password.encode(), db_user[0].encode()):
        return {"message": "Login successful"}
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")


# *******

# Read User Info
# Internal access: http://127.0.0.1:8000/userInfo?username=sayor
@app.get("/userInfo")
def getUserInfo(username: str = None):
    username = username if username is not None else 0
    cursor = conn.cursor()
    query = "SELECT username, email FROM users WHERE username=%s"
    cursor.execute(query, (username,))
    row = cursor.fetchone()
    cursor.close()
    conn.commit()

    print(row);

    if row:
        return {
            "username": row[0],
            "email": row[1],
        }
    else:
        return {}


# *******

# Read last weather data
# Internal access: http://127.0.0.1:8000/weather-data/get/last?location=Gazipur
@app.get("/weather-data/get/last")
def getLastWeatherData(location: str = None):
    location = location if location is not None else 0
    cursor = conn.cursor()
    query = "SELECT * FROM weather_data WHERE location=%s ORDER BY id DESC LIMIT 1"
    cursor.execute(query, (location,))
    row = cursor.fetchone()
    cursor.close()
    conn.commit()

    print(row);

    if row:
        return {
            "id": row[0],
            "temp": row[1],
            "humidity": row[2],
            "isRaining": row[3],
            "lightIntensity": row[4],
            "windSpeed": row[5],
            "airPressure": row[6],
        }
    else:
        return {}


# *******

# weather prediction
# Internal access: http://127.0.0.1:8000/weather-data/get-predicted-data?day=7&&month=2&&year=2012
@app.get("/weather-data/get-predicted-data")
def getPredictedWeatherData(day: int = None, month: int = None, year: int = None):
    day = day if day is not None else 0
    month = month if month is not None else 0
    year = year if year is not None else 0

    # Create a datetime object for the given date
    start_date = datetime(year, month, day)

    finalResult = []

    # Generate three consecutive dates starting from the given date
    for i in range(3):
        # Increment the date by one day
        current_date = start_date + timedelta(days=i)
        day = current_date.strftime('%d')
        month = current_date.strftime('%m')
        year = current_date.strftime('%Y')
        print(f"{day}-{month}-{year}")

        # load saved model
        with open('rf_model_pkl', 'rb') as f:
            rf_model = pickle.load(f)

        conditions_mapping = {
            0: 'Clear',
            1: 'Overcast',
            2: 'Partially cloudy',
            3: 'Rain',
            4: 'Rain, Overcast',
            5: 'Rain, Partially cloudy'
        }

        features = [[day, month, year]]

        # Predict the values
        predicted_values = rf_model.predict(features)

        # Print the predicted values
        tempmax = round(predicted_values[0][0], 3)
        tempmin = round(predicted_values[0][1], 3)
        temp = round(predicted_values[0][2], 3)
        humidity = round(predicted_values[0][3], 3)
        windspeed = round(predicted_values[0][4], 3)
        pressure = round(predicted_values[0][5], 3)
        conditions = round(predicted_values[0][6])

        print("Predicted tempmax (C):", tempmax)
        print("Predicted tempmin (C):", tempmin)
        print("Predicted temp (C):", temp)
        print("Predicted humidity (%):", humidity)
        print("Predicted windspeed (m/s):", windspeed)
        print("Predicted sea level pressure:", pressure)
        print("Predicted conditions:", conditions_mapping[conditions])

        finalResult.append({
                'date': f"{day}-{month}-{year}",
                'tempmax': tempmax,
                'tempmin': tempmin,
                'temp': temp,
                'humidity': humidity,
                'windspeed': windspeed,
                'pressure': pressure,
                'conditions': conditions_mapping[conditions]
            })


    return finalResult



# *******

# Get line chart data
# Internal access: http://127.0.0.1:8000/weather-data/line-chart
@app.get("/weather-data/line-chart")
def getLineChartData():
    cursor = conn.cursor()
    query = "SELECT windSpeed FROM weather_data WHERE location=%s ORDER BY id DESC LIMIT 10"
    cursor.execute(query, ("Gazipur",))
    rows = cursor.fetchall()
    cursor.close()
    conn.commit()

    ws = [];
    for row in rows:
        ws.append(row[0]);

    return ws

# *******

class User2(BaseModel):
    password: str
    email: str
    otp: int

@app.post("/forgot-password")
def forgotPassword(user: User2):
    print(user)
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    cursor = conn.cursor()

    query = "SELECT otp FROM otp WHERE email=%s"
    cursor.execute(query, (user.email,))
    row = cursor.fetchone()
    prevOtp = row[0]
    print(f'prevOtp: {prevOtp}')

    msg = ''
    status = ''
    if prevOtp == user.otp:
        print("OTP matched")
        query = "UPDATE users SET password=%s WHERE email=%s"
        cursor.execute(query, (hashed_password, user.email))
        status = 200
        msg = "Password updated successfully"
    else:
        print("OTP not matched")
        status = 403
        msg = "Otp not matched"

    print(f'msg: {msg}')
    print(f'status: {status}')

    conn.commit()
    cursor.close()
    return {
        'status': status,
        'msg': msg
    }

# *******

@app.get("/weather-data/create")
def newWeatherData(
        temp: float = None,
        humidity: float = None,
        isRaining: int = None,
        lightIntensity: float = None,
        windSpeed: float = None,
        pressure: float = None,
):
    # Handle oprional params value
    temp = temp if temp is not None else 0
    humidity = humidity if humidity is not None else 0
    isRaining = isRaining if isRaining is not None else 0
    lightIntensity = lightIntensity if lightIntensity is not None else 0
    windSpeed = windSpeed if windSpeed is not None else 0
    pressure = pressure if pressure is not None else 0

    cursor = conn.cursor()
    query = "INSERT INTO weather_data(temp, humidity, isRaining, lightIntensity, windSpeed, airPressure) VALUES (%s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (temp, humidity, isRaining, lightIntensity, windSpeed, pressure))
    affectedRows = cursor.rowcount
    cursor.close()
    conn.commit()
    if affectedRows == 1:
        return {"status": 200}
    else:
        return {"status": 403}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
