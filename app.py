from flask import Flask, render_template, request, redirect, url_for, jsonify, json
import cx_Oracle
import datetime
import os
from dotenv import load_dotenv

load_dotenv()
# --- ADD TO A .ENV FILE ---
# ORACLE_USERNAME = ""
# ORACLE_PASSWORD = ""
# ORACLE_HOST = ""
# ORACLE_PORT = ""
# ORACLE_SERVICE_NAME = ""
# FLASK_SECRET_KEY=""
# FLASK_DEBUG=True or False
# --- ADD TO A .ENV FILE ---

app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY", "default_key")

def get_connection():
    """
    Returns a new connection using the cx_Oracle driver.
    Ensure Oracle Instant Client or a full Oracle client is installed.
    """
    # Get credentials from environment variables
    user = os.getenv("ORACLE_USERNAME")
    pw = os.getenv("ORACLE_PASSWORD")
    host = os.getenv("ORACLE_HOST")
    port = os.getenv("ORACLE_PORT")
    service = os.getenv("ORACLE_SERVICE_NAME")

    # Optional: Add checks if variables are missing
    if not all([user, pw, host, port, service]):
         raise ValueError("Missing one or more Oracle connection environment variables (ORACLE_USERNAME, ORACLE_PASSWORD, ORACLE_HOST, ORACLE_PORT, ORACLE_SERVICE_NAME)")

    dsn_tns = cx_Oracle.makedsn(host, port, service_name=service)
    connection = cx_Oracle.connect(user=user, password=pw, dsn=dsn_tns)
    return connection

def fetch_cursor_data(cursor):
    """Fetches all rows from a cursor and returns them as a list of dictionaries."""
    columns = [col[0].lower() for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


# Helper to format data for Chart.js (labels, data)
def format_chart_data(cursor, label_col_index=0, data_col_index=1, date_format=None):
    labels = []
    data = []
    if cursor:
        raw_data = cursor.fetchall()
        for row in raw_data:
            label = row[label_col_index]
            if isinstance(label, datetime.datetime) and date_format:
                labels.append(label.strftime(date_format))
            else:
                labels.append(label)
            data.append(row[data_col_index])
    return {"labels": labels, "data": data}

# Helper to format scatter data (list of {x, y} objects)
def format_scatter_data(cursor, x_col_index=0, y_col_index=1):
    scatter_data = []
    if cursor:
        raw_data = cursor.fetchall()
        for row in raw_data:
             # Ensure data is numeric or handle potential errors/nulls
            x_val = row[x_col_index] if row[x_col_index] is not None else 0
            y_val = row[y_col_index] if row[y_col_index] is not None else 0
            scatter_data.append({"x": x_val, "y": y_val})
    return {"data": scatter_data}


@app.route('/')
def home():
    # Existing data structures
    dashboard_data = {
        "passenger_count": "N/A",
        "flight_count": "N/A",
        "booking_count": "N/A",
        "aircraft_count": "N/A",
        "crew_count": "N/A"
    }
    flights_chart_data = {"labels": [], "data": []}
    bookings_chart_data = {"labels": [], "data": []}
    aircraft_chart_data = {"labels": [], "data": []}

    # --- NEW: Data structures for additional plots ---
    passenger_age_data = {"labels": [], "data": []}
    payment_status_data = {"labels": [], "data": []}
    crew_role_data = {"labels": [], "data": []}
    bookings_trend_data = {"labels": [], "data": []}
    top_airports_data = {"labels": [], "data": []}
    flights_per_airport_data = {"labels": [], "data": []}
    bookings_capacity_data = {"data": []} # For scatter plot

    error = None
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        # --- Fetch Counts using Procedure (Existing) ---
        p_count = cursor.var(cx_Oracle.NUMBER)
        f_count = cursor.var(cx_Oracle.NUMBER)
        b_count = cursor.var(cx_Oracle.NUMBER)
        a_count = cursor.var(cx_Oracle.NUMBER)
        c_count = cursor.var(cx_Oracle.NUMBER)
        cursor.callproc("SP_GetDashboardCounts", [p_count, f_count, b_count, a_count, c_count])
        dashboard_data["passenger_count"] = int(p_count.getvalue()) if p_count.getvalue() != -1 else "Error"
        dashboard_data["flight_count"] = int(f_count.getvalue()) if f_count.getvalue() != -1 else "Error"
        dashboard_data["booking_count"] = int(b_count.getvalue()) if b_count.getvalue() != -1 else "Error"
        dashboard_data["aircraft_count"] = int(a_count.getvalue()) if a_count.getvalue() != -1 else "Error"
        dashboard_data["crew_count"] = int(c_count.getvalue()) if c_count.getvalue() != -1 else "Error"

        # --- Fetch Flights Per Day Chart Data (Existing) ---
        flights_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetFlightsPerDay", [30, flights_cursor_var]) # Get next 30 days
        flights_cursor = flights_cursor_var.getvalue()
        flights_chart_data = format_chart_data(flights_cursor, date_format='%Y-%m-%d')
        if flights_cursor: flights_cursor.close()

        # --- Fetch Booking Status Chart Data (Existing) ---
        bookings_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetBookingStatusDist", [bookings_cursor_var])
        bookings_cursor = bookings_cursor_var.getvalue()
        bookings_chart_data = format_chart_data(bookings_cursor)
        if bookings_cursor: bookings_cursor.close()

        # --- Fetch Aircraft Model Chart Data (Existing) ---
        aircraft_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetAircraftModelDist", [aircraft_cursor_var])
        aircraft_cursor = aircraft_cursor_var.getvalue()
        aircraft_chart_data = format_chart_data(aircraft_cursor)
        if aircraft_cursor: aircraft_cursor.close()

        # --- NEW: Fetch Passenger Age Distribution Data ---
        age_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetPassengerAgeDist", [age_cursor_var])
        age_cursor = age_cursor_var.getvalue()
        passenger_age_data = format_chart_data(age_cursor)
        if age_cursor: age_cursor.close()

        # --- NEW: Fetch Payment Status Distribution Data ---
        payment_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetPaymentStatusDist", [payment_cursor_var])
        payment_cursor = payment_cursor_var.getvalue()
        payment_status_data = format_chart_data(payment_cursor)
        if payment_cursor: payment_cursor.close()

        # --- NEW: Fetch Crew Role Distribution Data ---
        crew_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetCrewRoleDist", [crew_cursor_var])
        crew_cursor = crew_cursor_var.getvalue()
        crew_role_data = format_chart_data(crew_cursor)
        if crew_cursor: crew_cursor.close()

        # --- NEW: Fetch Bookings Trend Data ---
        bookings_trend_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetBookingsTrend", [30, bookings_trend_cursor_var]) # 30 days trend
        bookings_trend_cursor = bookings_trend_cursor_var.getvalue()
        bookings_trend_data = format_chart_data(bookings_trend_cursor, date_format='%Y-%m-%d')
        if bookings_trend_cursor: bookings_trend_cursor.close()

        # --- NEW: Fetch Top Departing Airports Data ---
        top_airports_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetTopDepartingAirports", [5, top_airports_cursor_var]) # Top 5
        top_airports_cursor = top_airports_cursor_var.getvalue()
        top_airports_data = format_chart_data(top_airports_cursor)
        if top_airports_cursor: top_airports_cursor.close()

        # --- NEW: Fetch Flights per Airport Data (Relationship Plot 1) ---
        flights_per_airport_cursor_var = cursor.var(cx_Oracle.CURSOR)
        # *** FIXED PROCEDURE NAME HERE ***
        cursor.callproc("SP_GetFlightsPerAirport", [flights_per_airport_cursor_var])
        flights_per_airport_cursor = flights_per_airport_cursor_var.getvalue()
        # Limit to top N for better visualization if needed, e.g., top 15
        temp_data = format_chart_data(flights_per_airport_cursor)
        flights_per_airport_data = {"labels": temp_data["labels"][:15], "data": temp_data["data"][:15]}
        if flights_per_airport_cursor: flights_per_airport_cursor.close()

        # --- NEW: Fetch Avg Bookings vs Capacity Data (Relationship Plot 2) ---
        bookings_capacity_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetAvgBookingsVsCapacity", [bookings_capacity_cursor_var])
        bookings_capacity_cursor = bookings_capacity_cursor_var.getvalue()
        bookings_capacity_data = format_scatter_data(bookings_capacity_cursor)
        if bookings_capacity_cursor: bookings_capacity_cursor.close()

    # *** ENSURE CORRECT INDENTATION FOR except, finally, and return ***
    except Exception as e:
        # Log error: print(f"Dashboard Error: {e}")
        error = f"Could not load dashboard data: {str(e)}"
        # Reset all data on error
        for key in dashboard_data: dashboard_data[key] = "Error"
        flights_chart_data = {"labels": [], "data": []}
        bookings_chart_data = {"labels": [], "data": []}
        aircraft_chart_data = {"labels": [], "data": []}
        # --- Reset new data structures on error ---
        passenger_age_data = {"labels": [], "data": []}
        payment_status_data = {"labels": [], "data": []}
        crew_role_data = {"labels": [], "data": []}
        bookings_trend_data = {"labels": [], "data": []}
        top_airports_data = {"labels": [], "data": []}
        flights_per_airport_data = {"labels": [], "data": []}
        bookings_capacity_data = {"data": []}

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

    # Render index.html, passing all fetched data
    return render_template('index.html',
                           dashboard_data=dashboard_data,
                           flights_chart_data=flights_chart_data,
                           bookings_chart_data=bookings_chart_data,
                           aircraft_chart_data=aircraft_chart_data,
                           # --- Pass new plot data ---
                           passenger_age_data=passenger_age_data,
                           payment_status_data=payment_status_data,
                           crew_role_data=crew_role_data,
                           bookings_trend_data=bookings_trend_data,
                           top_airports_data=top_airports_data,
                           flights_per_airport_data=flights_per_airport_data,
                           bookings_capacity_data=bookings_capacity_data,
                           error=error)

# 1) PL/SQL Executor
@app.route('/executor', methods=['GET', 'POST'])
def executor():
    result = None
    error = None
    if request.method == 'POST':
        script = request.form.get('script')
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute(script)
            conn.commit()
            result = "Script executed successfully."
        except Exception as e:
            error = str(e)
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    return render_template('executor.html', result=result, error=error)


@app.route('/check_connection')
def check_connection():
    try:
        conn = get_connection()
        conn.close()
        return "Successfully connected to the Oracle database!"
    except Exception as e:
        return f"Failed to connect to the Oracle database: {str(e)}"


# 2) Flight Search
@app.route('/search_flights', methods=['GET', 'POST'])
def search_flights():
    flights = []
    if request.method == 'POST':
        departure_airport = request.form.get('departure_airport')
        arrival_airport = request.form.get('arrival_airport')
        departure_date = request.form.get('departure_date')
        flight_number = request.form.get('flight_number')
        status = request.form.get('status')
        query = """
            SELECT flight_id, flight_number, departure_time, arrival_time, status
            FROM Flights
            WHERE 1=1
        """
        params = {}
        if departure_airport:
            query += " AND departure_airport_id = :dep"
            params["dep"] = departure_airport
        if arrival_airport:
            query += " AND arrival_airport_id = :arr"
            params["arr"] = arrival_airport
        if departure_date:
            query += " AND TRUNC(departure_time) = TO_DATE(:dep_date, 'YYYY-MM-DD')"
            params["dep_date"] = departure_date
        if flight_number:
            query += " AND flight_number = :fn"
            params["fn"] = flight_number
        if status:
            query += " AND status = :st"
            params["st"] = status
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute(query, params)
            flights = cursor.fetchall()
        except Exception as e:
            return f"Error searching flights: {str(e)}"
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
        return render_template('flight_results.html', flights=flights)
    else:
        return render_template('search_flights.html')


# 3) Booking a Flight
@app.route('/book_flight/<int:flight_id>', methods=['GET', 'POST'])
def book_flight(flight_id):
    if request.method == 'POST':
        passenger_id = request.form.get('passenger_id')
        seat_number = request.form.get('seat_number')
        new_booking_id = None
        error_message_from_db = None
        conn = None # Initialize conn
        try:
            conn = get_connection()
            cursor = conn.cursor()

            # Prepare variables for OUT parameters
            out_booking_id_var = cursor.var(cx_Oracle.NUMBER)
            out_error_msg_var = cursor.var(cx_Oracle.STRING, 2000) # Max size for error msg

            # Call the stored procedure
            cursor.callproc("SP_CreateBooking", [
                passenger_id,         # p_passenger_id (IN)
                flight_id,            # p_flight_id (IN)
                seat_number,          # p_seat_number (IN)
                out_booking_id_var,   # o_booking_id (OUT)
                out_error_msg_var     # o_error_msg (OUT)
            ])

            # Get the values from the OUT parameters
            new_booking_id = out_booking_id_var.getvalue()
            error_message_from_db = out_error_msg_var.getvalue()

            if error_message_from_db:
                # An error occurred within the stored procedure
                conn.rollback() # Rollback the transaction
                # Display the error from the procedure
                # You might want to render an error template instead of returning raw text
                return f"Database Error: {error_message_from_db}"
            elif new_booking_id is None:
                # Procedure might have indicated failure without an explicit Oracle error
                conn.rollback()
                return "Booking failed for an unknown reason (check procedure logic)."
            else:
                # Success! Commit the transaction started by the connection
                conn.commit()
                return redirect(url_for('booking_confirmation', booking_id=new_booking_id))

        except Exception as e:
            # An error occurred in the Python code or connecting/calling
            if conn:
                conn.rollback() # Rollback if connection was established
            # Log the full error e for debugging
            print(f"Python-level error during booking: {e}")
            return f"Application Error: Could not process booking." # User-friendly error
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
            if conn:
                conn.close()
    else:
        # GET request
        return render_template('book_flight.html', flight_id=flight_id)


@app.route('/booking_confirmation/<int:booking_id>')
def booking_confirmation(booking_id):
    booking_info = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        query = """
            SELECT booking_id, passenger_id, flight_id, booking_date, seat_number, booking_status
            FROM Bookings
            WHERE booking_id = :bid
        """
        cursor.execute(query, bid=booking_id)
        booking_info = cursor.fetchone()
    except Exception as e:
        return f"Error retrieving booking info: {str(e)}"
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()
    return render_template('booking_confirmation.html', booking_info=booking_info)


# 4) Manage Bookings
@app.route('/manage_bookings', methods=['GET', 'POST'])
def manage_bookings():
    bookings = []
    passenger_id = None
    if request.method == 'POST':
        passenger_id = request.form.get('passenger_id')
        action = request.form.get('action')
        booking_id = request.form.get('booking_id')
        try:
            conn = get_connection()
            cursor = conn.cursor()
            if action == 'search':
                query = """
                    SELECT booking_id, flight_id, booking_date, seat_number, booking_status
                    FROM Bookings
                    WHERE passenger_id = :pid
                """
                cursor.execute(query, pid=passenger_id)
                bookings = cursor.fetchall()
            elif action == 'cancel' and booking_id:
                query = """
                    UPDATE Bookings
                    SET booking_status = 'Cancelled'
                    WHERE booking_id = :bid
                """
                cursor.execute(query, bid=booking_id)
                conn.commit()
                return "Booking cancelled successfully."
        except Exception as e:
            return f"Error managing bookings: {str(e)}"
        finally:
            if 'cursor' in locals():
                cursor.close()
            if 'conn' in locals():
                conn.close()
    return render_template('search_bookings.html', bookings=bookings, passenger_id=passenger_id)

@app.route('/flight_details/<int:flight_id>')
def flight_details(flight_id):
    flight_info = None
    passengers = []
    error = None
    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Fetch flight details using the provided flight_id
        flight_query = """
            SELECT flight_id, flight_number, departure_time, arrival_time, status
            FROM Flights
            WHERE flight_id = :fid
        """
        cursor.execute(flight_query, fid=flight_id)
        flight_data = cursor.fetchone()

        if flight_data:
            # Convert to a dictionary or keep as tuple/list
            # Let's make it a dictionary for easier access in template potentially
            cols = [col[0].lower() for col in cursor.description]
            flight_info = dict(zip(cols, flight_data))

            # Fetch associated passengers if flight exists
            passenger_cursor = conn.cursor() # Use a new cursor
            passenger_query = """
                SELECT p.passenger_id, p.first_name, p.last_name, p.email, b.seat_number
                FROM Bookings b
                JOIN Passengers p ON b.passenger_id = p.passenger_id
                WHERE b.flight_id = :fid AND b.booking_status = 'Confirmed'
                ORDER BY b.seat_number
            """
            passenger_cursor.execute(passenger_query, fid=flight_id)
            # Keep passengers as list of lists/tuples or convert to dicts
            pass_cols = [col[0].lower() for col in passenger_cursor.description]
            passengers = [dict(zip(pass_cols, row)) for row in passenger_cursor.fetchall()]
            passenger_cursor.close()

        else:
            error = "Flight not found."

    except Exception as e:
        # Log error: print(f"Error fetching flight details for {flight_id}: {e}")
        error = f"An error occurred while fetching flight details: {str(e)}"
        flight_info = None
        passengers = []
    finally:
        if cursor: # Close the main cursor
            cursor.close()
        if conn:
            conn.close()

    # Render the detail template (renamed from flight_details.html)
    return render_template('flight_details.html',
                           flight_info=flight_info,
                           passengers=passengers,
                           error=error)


# 6) View Table Data
@app.route('/view_table', methods=['GET', 'POST'])
def view_table():
    table_names = ["Aircraft", "Airports", "Flights", "Passengers", "Bookings", "Crew", "Schedules", "Payments"]
    data = None
    columns = None
    selected_table = None
    error = None

    if request.method == 'POST':
        selected_table = request.form.get('table_name')
        if selected_table not in table_names:
            error = "Invalid table selected."
        else:
            try:
                conn = get_connection()
                cursor = conn.cursor()
                query = f"SELECT * FROM {selected_table}"
                cursor.execute(query)
                raw_data = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description]

                # Convert datetime objects to a standard string format
                data = []
                for row in raw_data:
                    row_list = []
                    for val in row:
                        if isinstance(val, datetime.datetime):
                            # Use a standard format for date/time
                            val = val.strftime('%Y-%m-%d')
                            # or val = val.strftime('%Y-%m-%d %H:%M:%S') if you have time components
                        row_list.append(val)
                    data.append(row_list)

            except Exception as e:
                error = str(e)
            finally:
                if 'cursor' in locals():
                    cursor.close()
                if 'conn' in locals():
                    conn.close()
    return render_template('view_table.html',
                           table_names=table_names,
                           selected_table=selected_table,
                           data=data,
                           columns=columns,
                           error=error)

# 7) Insert Entity (with auto-generated IDs)
@app.route('/insert', methods=['GET', 'POST'])
def insert_entity():
    # If the page is loaded via GET, check for a preselected entity from view_table
    preselected = None
    if request.method == 'GET':
        preselected = request.args.get('entity')
    message = None
    if request.method == 'POST':
        entity = request.form.get('entity')
        try:
            conn = get_connection()
            cursor = conn.cursor()
            if entity == "Passengers":
                cursor.execute("SELECT NVL(MAX(passenger_id), 0) + 1 FROM Passengers")
                new_id = cursor.fetchone()[0]
                first_name = request.form.get('first_name')
                last_name = request.form.get('last_name')
                email = request.form.get('email')
                phone = request.form.get('phone')
                date_of_birth = request.form.get('date_of_birth')
                passport_number = request.form.get('passport_number')
                query = """
                    INSERT INTO Passengers (passenger_id, first_name, last_name, email, phone, date_of_birth, passport_number)
                    VALUES (:pid, :fname, :lname, :email, :phone, TO_DATE(:dob, 'YYYY-MM-DD'), :passport)
                """
                cursor.execute(query, pid=new_id, fname=first_name, lname=last_name, email=email,
                               phone=phone, dob=date_of_birth, passport=passport_number)
                message = f"Passenger inserted successfully with ID {new_id}."
            elif entity == "Flights":
                cursor.execute("SELECT NVL(MAX(flight_id), 0) + 1 FROM Flights")
                new_id = cursor.fetchone()[0]
                flight_number = request.form.get('flight_number')
                aircraft_id = request.form.get('aircraft_id')
                departure_airport_id = request.form.get('departure_airport_id')
                arrival_airport_id = request.form.get('arrival_airport_id')
                departure_time = request.form.get('departure_time')
                arrival_time = request.form.get('arrival_time')
                status = request.form.get('status')
                query = """
                    INSERT INTO Flights (flight_id, flight_number, aircraft_id, departure_airport_id, arrival_airport_id, departure_time, arrival_time, status)
                    VALUES (:fid, :fnum, :aid, :dep_airport, :arr_airport, TO_TIMESTAMP(:dep_time, 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP(:arr_time, 'YYYY-MM-DD HH24:MI:SS'), :status)
                """
                cursor.execute(query, fid=new_id, fnum=flight_number, aid=aircraft_id,
                               dep_airport=departure_airport_id, arr_airport=arrival_airport_id,
                               dep_time=departure_time, arr_time=arrival_time, status=status)
                message = f"Flight inserted successfully with ID {new_id}."
            elif entity == "Aircraft":
                cursor.execute("SELECT NVL(MAX(aircraft_id), 0) + 1 FROM Aircraft")
                new_id = cursor.fetchone()[0]
                model = request.form.get('model')
                manufacturer = request.form.get('manufacturer')
                capacity = request.form.get('capacity')
                registration_number = request.form.get('registration_number')
                year_built = request.form.get('year_built')
                query = """
                    INSERT INTO Aircraft (aircraft_id, model, manufacturer, capacity, registration_number, year_built)
                    VALUES (:aid, :model, :manufacturer, :capacity, :reg, :year)
                """
                cursor.execute(query, aid=new_id, model=model, manufacturer=manufacturer,
                               capacity=capacity, reg=registration_number, year=year_built)
                message = f"Airplane inserted successfully with ID {new_id}."
            elif entity == "Bookings":
                cursor.execute("SELECT NVL(MAX(booking_id), 0) + 1 FROM Bookings")
                new_id = cursor.fetchone()[0]
                passenger_id = request.form.get('passenger_id')
                flight_id = request.form.get('flight_id')
                seat_number = request.form.get('seat_number')
                booking_status = request.form.get('booking_status')
                query = """
                    INSERT INTO Bookings (booking_id, passenger_id, flight_id, booking_date, seat_number, booking_status)
                    VALUES (:bid, :pid, :fid, SYSDATE, :seat, :status)
                """
                cursor.execute(query, bid=new_id, pid=passenger_id, fid=flight_id, seat=seat_number, status=booking_status)
                message = f"Booking inserted successfully with ID {new_id}."
            elif entity == "Crew":
                cursor.execute("SELECT NVL(MAX(crew_id), 0) + 1 FROM Crew")
                new_id = cursor.fetchone()[0]
                first_name = request.form.get('first_name')
                last_name = request.form.get('last_name')
                role = request.form.get('role')
                phone = request.form.get('phone')
                email = request.form.get('email')
                query = """
                    INSERT INTO Crew (crew_id, first_name, last_name, role, phone, email)
                    VALUES (:cid, :fname, :lname, :role, :phone, :email)
                """
                cursor.execute(query, cid=new_id, fname=first_name, lname=last_name,
                               role=role, phone=phone, email=email)
                message = f"Crew member inserted successfully with ID {new_id}."
            conn.commit()
            cursor.close()
            conn.close()
            # Redirect after successful insertion
            return redirect(url_for('view_table'))
        except Exception as e:
            message = f"Error inserting {entity}: {str(e)}"
    return render_template('insert_entity.html', message=message, preselected=preselected)


# 8) Update Entity (Inline Editing)
@app.route('/update_entity', methods=['POST'])
def update_entity():
    # Map each table to its primary key and its DATE/TIMESTAMP columns (if any)
    pk_map = {
        "Aircraft": ("aircraft_id", []),
        "Airports": ("airport_id", []),
        "Flights": ("flight_id", ["DEPARTURE_TIME", "ARRIVAL_TIME"]),
        "Passengers": ("passenger_id", ["DATE_OF_BIRTH"]),
        "Bookings": ("booking_id", ["BOOKING_DATE"]),
        "Crew": ("crew_id", []),
        "Schedules": ("schedule_id", []),
        "Payments": ("payment_id", [])
    }
    table_name = request.form.get('table_name')
    primary_key_value = request.form.get('primary_key_value')
    pk_column, date_cols = pk_map.get(table_name, ("id", []))

    set_clauses = []
    params = {}
    for key in request.form:
        if key not in ["table_name", "primary_key_value"]:
            # If this column is a date column, wrap value with TO_DATE
            if key.upper() in [dc.upper() for dc in date_cols]:
                set_clauses.append(f"{key} = TO_DATE(:{key}, 'YYYY-MM-DD')")
            else:
                set_clauses.append(f"{key} = :{key}")
            params[key] = request.form.get(key)
    params["pk_value"] = primary_key_value
    query = f"UPDATE {table_name} SET {', '.join(set_clauses)} WHERE {pk_column} = :pk_value"
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()
        cursor.close()
        conn.close()
        return redirect(url_for('view_table'))
    except Exception as e:
        return f"Error updating entity: {str(e)}"


# 9) Delete Entity (Inline Deletion)
@app.route('/delete_entity')
def delete_entity():
    table_name = request.args.get('table_name')
    primary_key_value = request.args.get('primary_key_value')
    pk_column = {
        "Aircraft": "aircraft_id",
        "Airports": "airport_id",
        "Flights": "flight_id",
        "Passengers": "passenger_id",
        "Bookings": "booking_id",
        "Crew": "crew_id",
        "Schedules": "schedule_id",
        "Payments": "payment_id"
    }.get(table_name, "id")
    query = f"DELETE FROM {table_name} WHERE {pk_column} = :pk_value"
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(query, pk_value=primary_key_value)
        conn.commit()
        cursor.close()
        conn.close()
        return redirect(url_for('view_table'))
    except Exception as e:
        return f"Error deleting entity: {str(e)}"


# --- API Route to get seat layout for a specific flight ---
@app.route('/api/get_seat_layout/<int:flight_id>')
def get_seat_layout(flight_id):
    conn = None
    capacity = 0
    booked_seats_list = []
    error = None
    try:
        conn = get_connection()
        cursor = conn.cursor()

        out_capacity_var = cursor.var(cx_Oracle.NUMBER)
        out_booked_seats_cursor_var = cursor.var(cx_Oracle.CURSOR)

        cursor.callproc("SP_GetFlightLayout", [
            flight_id,
            out_capacity_var,
            out_booked_seats_cursor_var
        ])

        capacity = out_capacity_var.getvalue()
        booked_seats_cursor = out_booked_seats_cursor_var.getvalue()

        if capacity == -1: # Check for error indicator from procedure
             error = "Could not retrieve aircraft capacity for this flight."
        elif capacity == 0:
             error = "Flight not found or has no capacity assigned."
        elif booked_seats_cursor:
             # Fetch only the seat number column
             booked_seats_list = [row[0] for row in booked_seats_cursor.fetchall() if row[0]] # Extract seat numbers
             booked_seats_cursor.close()
        else:
             error = "Could not retrieve booked seats information."


    except Exception as e:
         # Log error: print(f"Error fetching seat layout for flight {flight_id}: {e}")
         error = "Server error retrieving seat layout."
         capacity = 0
         booked_seats_list = []
    finally:
         if 'cursor' in locals() and cursor:
             cursor.close()
         if conn:
             conn.close()

    if error:
        return jsonify({"error": error}), 500 # Return error status
    else:
        return jsonify({
            "capacity": capacity,
            "booked_seats": booked_seats_list
        })


@app.route('/create_booking', methods=['GET', 'POST'])
def create_booking():
    conn = None
    passengers = []
    flights = []
    airports = []
    error = None
    booking_success_id = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        if request.method == 'POST':
            # --- Handle FINAL booking submission ---
            passenger_type = request.form.get('passenger_type')
            flight_id = request.form.get('flight_id')
            seat_number = request.form.get('selected_seat')
            passenger_id = None

            # Validate required fields
            if not flight_id or not seat_number:
                 error = "Flight and Seat Number are required."
                 # Re-fetch data for form repopulation (see GET block)
            else:
                 if passenger_type == 'new':
                     # Create new passenger first
                     out_passenger_id_var = cursor.var(cx_Oracle.NUMBER)
                     out_error_msg_var = cursor.var(cx_Oracle.STRING, 2000)
                     dob_str = request.form.get('new_date_of_birth', '')

                     cursor.callproc("SP_CreatePassenger", [
                         request.form.get('new_first_name', ''),
                         request.form.get('new_last_name', ''),
                         request.form.get('new_email', ''),
                         request.form.get('new_phone', ''),
                         dob_str, # Pass as string
                         request.form.get('new_passport_number', ''),
                         out_passenger_id_var,
                         out_error_msg_var
                     ])
                     passenger_id = out_passenger_id_var.getvalue()
                     db_error = out_error_msg_var.getvalue()
                     if db_error:
                         error = f"Passenger Creation Failed: {db_error}"
                     elif passenger_id is None:
                         error = "Passenger creation failed for an unknown reason."

                 elif passenger_type == 'existing':
                     passenger_id = request.form.get('existing_passenger_id')
                     if not passenger_id:
                         error = "Please select an existing passenger."
                 else:
                     error = "Invalid passenger type selected."

                 # If passenger is OK, proceed to create booking
                 if passenger_id and not error:
                     out_booking_id_var = cursor.var(cx_Oracle.NUMBER)
                     out_booking_error_var = cursor.var(cx_Oracle.STRING, 2000)

                     cursor.callproc("SP_CreateBooking", [
                         passenger_id,
                         flight_id,
                         seat_number,
                         out_booking_id_var,
                         out_booking_error_var
                     ])

                     booking_id = out_booking_id_var.getvalue()
                     booking_error = out_booking_error_var.getvalue()

                     if booking_error:
                         error = f"Booking Failed: {booking_error}"
                         conn.rollback() # Rollback failed booking attempt
                     elif booking_id:
                         conn.commit() # Commit successful booking
                         # Redirect to confirmation page (or show message here)
                         return redirect(url_for('booking_confirmation', booking_id=booking_id))
                         # Or: booking_success_id = booking_id
                     else:
                         error = "Booking failed for an unknown database reason."
                         conn.rollback()
                 else:
                      # Passenger ID missing or error during creation
                      if not error: # If no specific error was set yet
                           error = "Could not determine passenger for booking."
                      conn.rollback() # Rollback if passenger creation failed within POST

        # --- Always Fetch data for GET request or for repopulating form after POST error ---
        # Get Passengers
        passenger_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetPassengerList", [passenger_cursor_var])
        passenger_cursor = passenger_cursor_var.getvalue()
        passengers = fetch_cursor_data(passenger_cursor)
        passenger_cursor.close()

        # Get Flights (apply filters from query params if present)
        dep_loc_filter = request.args.get('dep_loc') # Or request.form.get if using POST for filter
        arr_loc_filter = request.args.get('arr_loc')
        start_date_filter = request.args.get('start_date')
        end_date_filter = request.args.get('end_date')

        flight_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetAvailableFlights", [
            dep_loc_filter, arr_loc_filter, start_date_filter, end_date_filter, flight_cursor_var
        ])
        flight_cursor = flight_cursor_var.getvalue()
        flights = fetch_cursor_data(flight_cursor)
        flight_cursor.close()

        # Get Airports (for filter dropdowns)
        airport_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetAirports", [airport_cursor_var])
        airport_cursor = airport_cursor_var.getvalue()
        airports = fetch_cursor_data(airport_cursor) if airport_cursor else []
        if airport_cursor: airport_cursor.close()

        print("--- Debug: Airports Data ---")
        print(airports)
        print("--- End Debug ---")

    except Exception as e:
        # Log the full error for debugging: print(f"Error in /create_booking: {e}")
        if conn:
             conn.rollback() # Rollback on Python level error too
        error = f"An application error occurred: {str(e)}"
        # Reset data lists on error to prevent potentially inconsistent state
        passengers = []
        flights = []
        airports = []
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if conn:
            conn.close()

    # Render the template, passing fetched data and any error messages
    # Pass request.form to preserve user input after POST error
    return render_template('create_booking.html',
                           passengers=passengers,
                           flights=flights,
                           airports=airports,
                           error=error,
                           booking_success_id=booking_success_id,
                           form_data=request.form if request.method == 'POST' else {})

@app.route('/search_bookings', methods=['GET', 'POST'])
# Ensure the function name is 'search_bookings'
def search_bookings():
    bookings = []
    passengers = []
    error = None
    search_criteria = {} # Define it early

    conn = None
    cursor = None

    try:
        conn = get_connection()
        cursor = conn.cursor()

        # --- Always fetch passengers ---
        passenger_cursor_var = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("SP_GetPassengerList", [passenger_cursor_var])
        passenger_cursor = passenger_cursor_var.getvalue()
        if passenger_cursor:
            # Use the helper function if defined, otherwise basic fetch
            # passengers = fetch_cursor_data(passenger_cursor) # Preferred
            passengers = [dict(zip([col[0].lower() for col in passenger_cursor.description], row)) for row in passenger_cursor.fetchall()] # Basic fetch
            passenger_cursor.close()


        if request.method == 'POST':
            action = request.form.get('action')

            # --- Repopulate search_criteria from form for POST ---
            # (Do this even if cancelling, though redirecting is better)
            search_criteria['booking_id'] = request.form.get('booking_id', '') # Use .get for safety
            search_criteria['passenger_id'] = request.form.get('passenger_id', '')

            if action == 'search':
                search_booking_id = search_criteria['booking_id'] or None
                search_passenger_id = search_criteria['passenger_id'] or None

                if not search_booking_id and not search_passenger_id:
                    error = "Please enter a Booking ID or select a Passenger to search."
                else:
                    # ... (rest of search logic using SP_SearchBookings) ...
                    # Make sure 'bookings' list gets populated here
                    booking_cursor_var = cursor.var(cx_Oracle.CURSOR)
                    cursor.callproc("SP_SearchBookings", [
                        search_booking_id,
                        search_passenger_id,
                        booking_cursor_var
                    ])
                    booking_cursor = booking_cursor_var.getvalue()
                    if booking_cursor:
                         # Use the helper function if defined, otherwise basic fetch
                        # bookings = fetch_cursor_data(booking_cursor) # Preferred
                        bookings = [dict(zip([col[0].lower() for col in booking_cursor.description], row)) for row in booking_cursor.fetchall()] # Basic fetch
                        booking_cursor.close()
                    if not bookings:
                         error = "No bookings found matching your criteria."


            elif action == 'cancel':
                # ... (cancel logic) ...
                 # After successful cancel, redirect to avoid re-POST on refresh
                return redirect(url_for('search_bookings'))


    except Exception as e:
        # ... (error handling) ...
        error = f"An application error occurred: {str(e)}"
        # Ensure passengers is defined even on error if needed by template
        if 'passengers' not in locals(): passengers = []

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

    # --- Ensure the render_template uses the CORRECT filename and passes search_criteria ---
    return render_template('search_bookings.html',
                           bookings=bookings,
                           passengers=passengers,
                           search_criteria=search_criteria, # Pass the dictionary
                           error=error)


if __name__ == '__main__':
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(debug=debug_mode)