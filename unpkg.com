
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mission Rakshak - Indian Soldier Survival Assistant</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        :root {
            --army-green: #0d4d1d;
            --army-gold: #c9a145;
            --army-dark: #121e12;
            --army-light: #e9f5e9;
            --danger-red: #c82333;
            --success-green: #28a745;
            --map-green: #1d5c1a;
            --map-border: #8B4513;
        }

        body {
            background: linear-gradient(135deg, var(--army-dark), #0a3a17);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Login Screen */
        .login-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            padding: 20px;
        }

        .login-card {
            background: rgba(10, 58, 23, 0.9);
            border-radius: 15px;
            padding: 40px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            border: 2px solid var(--army-gold);
            text-align: center;
        }

        .login-logo {
            margin-bottom: 30px;
        }

        .login-logo i {
            font-size: 4rem;
            color: var(--army-gold);
            margin-bottom: 15px;
        }

        .login-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .login-subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 30px;
            color: var(--army-gold);
        }

        .login-form {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .form-group {
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--army-gold);
        }

        .form-control {
            width: 100%;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid rgba(201, 161, 69, 0.3);
            background: rgba(0, 0, 0, 0.4);
            color: white;
            font-size: 1.1rem;
        }

        .login-btn {
            background: var(--army-gold);
            color: #0a3a17;
            border: none;
            padding: 15px;
            border-radius: 8px;
            font-size: 1.2rem;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
        }

        .login-btn:hover {
            background: #d4b04c;
            transform: translateY(-3px);
        }

        .app-footer {
            text-align: center;
            margin-top: 30px;
            font-size: 0.9rem;
            opacity: 0.8;
        }

        /* Main App */
        #main-app {
            display: none;
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .app-header {
            background: rgba(10, 58, 23, 0.9);
            border-radius: 15px;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
            margin-bottom: 20px;
            border: 1px solid var(--army-gold);
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .app-logo {
            display: flex;
            align-items: center;
        }

        .app-logo i {
            font-size: 2.2rem;
            color: var(--army-gold);
            margin-right: 12px;
        }

        .app-title {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .app-tagline {
            font-size: 0.95rem;
            opacity: 0.9;
            margin-top: 3px;
            color: #e0e0e0;
        }

        .utility-icons {
            display: flex;
            gap: 15px;
        }

        .utility-btn {
            background: rgba(201, 161, 69, 0.2);
            border: 1px solid var(--army-gold);
            color: var(--army-gold);
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 1.2rem;
        }

        .utility-btn:hover {
            background: rgba(201, 161, 69, 0.3);
            transform: scale(1.1);
        }

        .sos-btn {
            background: linear-gradient(to right, #ff4d4d, #c82333);
            color: white;
            border: none;
            padding: 12px 28px;
            border-radius: 30px;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            align-items: center;
            box-shadow: 0 4px 15px rgba(200, 35, 51, 0.4);
            transition: all 0.3s;
            font-size: 1.1rem;
            position: relative;
            overflow: hidden;
        }

        .sos-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(200, 35, 51, 0.6);
        }

        .sos-btn i {
            margin-right: 8px;
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }

        /* Main Content Layout */
        .main-content {
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 20px;
            min-height: 80vh;
        }

        /* Sidebar */
        .sidebar {
            background: rgba(10, 40, 15, 0.85);
            border-radius: 15px;
            display: flex;
            flex-direction: column;
            padding: 15px 0;
            border: 1px solid rgba(201, 161, 69, 0.3);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .user-info {
            padding: 20px;
            display: flex;
            align-items: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .user-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--army-gold);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.5rem;
            margin-right: 15px;
            color: #0a3a17;
            border: 2px solid rgba(255, 255, 255, 0.5);
        }

        .user-details {
            flex: 1;
        }

        .user-name {
            font-weight: 600;
            font-size: 1.1rem;
            color: var(--army-gold);
        }

        .user-role {
            font-size: 0.85rem;
            opacity: 0.9;
        }

        .nav-links {
            padding: 20px 0;
            flex: 1;
        }

        .nav-item {
            padding: 16px 25px;
            display: flex;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s;
            border-left: 4px solid transparent;
            margin-bottom: 5px;
            font-size: 1.05rem;
        }

        .nav-item:hover {
            background: rgba(201, 161, 69, 0.1);
        }

        .nav-item.active {
            background: rgba(201, 161, 69, 0.2);
            border-left: 4px solid var(--army-gold);
        }

        .nav-item i {
            margin-right: 15px;
            font-size: 1.3rem;
            width: 30px;
            text-align: center;
            color: var(--army-gold);
        }

        /* Content Area */
        .content-area {
            background: rgba(0, 0, 0, 0.5);
            border-radius: 15px;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            border: 1px solid rgba(201, 161, 69, 0.3);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .content-header {
            padding: 18px 30px;
            background: rgba(13, 77, 29, 0.6);
            border-bottom: 1px solid rgba(201, 161, 69, 0.3);
        }

        .page-title {
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--army-gold);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .page-title i {
            font-size: 1.4rem;
        }

        .screen {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
            display: none;
        }

        .screen.active {
            display: block;
        }

        /* AI Assistant */
        .ai-assistant {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .chat-container {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: rgba(0, 0, 0, 0.3);
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid rgba(201, 161, 69, 0.2);
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            max-width: 85%;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .user-message {
            margin-left: auto;
        }

        .message-content {
            padding: 15px 20px;
            border-radius: 18px;
            display: inline-block;
            background: rgba(13, 77, 29, 0.7);
            border: 1px solid rgba(201, 161, 69, 0.3);
            line-height: 1.5;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.2);
        }

        .user-message .message-content {
            background: rgba(201, 161, 69, 0.25);
            border-bottom-right-radius: 5px;
        }

        .ai-message .message-content {
            border-bottom-left-radius: 5px;
        }

        .message-time {
            font-size: 0.75rem;
            opacity: 0.7;
            margin-top: 8px;
            font-style: italic;
        }

        .user-message .message-time {
            text-align: right;
        }

        .input-container {
            display: flex;
            gap: 12px;
            margin-top: 10px;
        }

        .message-input {
            flex: 1;
            padding: 16px 20px;
            border: 1px solid rgba(201, 161, 69, 0.3);
            border-radius: 30px;
            font-size: 1.05rem;
            background: rgba(0, 0, 0, 0.4);
            color: white;
            transition: all 0.3s;
        }

        .message-input:focus {
            outline: none;
            border-color: var(--army-gold);
            box-shadow: 0 0 0 2px rgba(201, 161, 69, 0.3);
        }

        .voice-btn, .send-btn {
            width: 55px;
            height: 55px;
            border-radius: 50%;
            border: none;
            background: var(--army-gold);
            color: #0a3a17;
            font-size: 1.3rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            font-weight: bold;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.3);
        }

        .voice-btn:hover, .send-btn:hover {
            background: #d4b04c;
            transform: scale(1.05);
        }

        .status-container {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }

        .connection-status {
            padding: 10px 18px;
            background: rgba(255, 152, 0, 0.3);
            color: white;
            border-radius: 20px;
            display: inline-flex;
            align-items: center;
            font-size: 0.95rem;
            border: 1px solid rgba(255, 152, 0, 0.5);
        }

        .connection-status.online {
            background: rgba(40, 167, 69, 0.3);
            border: 1px solid rgba(40, 167, 69, 0.5);
        }

        .connection-status i {
            margin-right: 8px;
        }

        .language-indicator {
            padding: 10px 18px;
            background: rgba(13, 77, 29, 0.5);
            color: white;
            border-radius: 20px;
            display: inline-flex;
            align-items: center;
            font-size: 0.95rem;
            border: 1px solid rgba(201, 161, 69, 0.5);
        }

        /* Family Contact */
        .contacts-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
        }

        .contact-card {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid rgba(201, 161, 69, 0.2);
            transition: all 0.3s;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .contact-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
            border-color: var(--army-gold);
        }

        .contact-header {
            background: linear-gradient(to right, rgba(13, 77, 29, 0.7), rgba(10, 58, 23, 0.7));
            padding: 22px;
            display: flex;
            align-items: center;
            border-bottom: 1px solid rgba(201, 161, 69, 0.2);
        }

        .contact-avatar {
            width: 65px;
            height: 65px;
            border-radius: 50%;
            background: var(--army-gold);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.6rem;
            margin-right: 18px;
            color: #0a3a17;
            border: 2px solid rgba(255, 255, 255, 0.5);
        }

        .contact-info h3 {
            margin-bottom: 6px;
            color: var(--army-gold);
            font-size: 1.3rem;
        }

        .contact-info p {
            font-size: 0.95rem;
            opacity: 0.9;
        }

        .contact-body {
            padding: 22px;
        }

        .contact-field {
            display: flex;
            align-items: center;
            margin-bottom: 14px;
        }

        .contact-field i {
            width: 30px;
            color: var(--army-gold);
            margin-right: 12px;
            font-size: 1.2rem;
        }

        .contact-actions {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }

        .contact-btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 8px;
            background: rgba(201, 161, 69, 0.2);
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            font-size: 1.05rem;
        }

        .contact-btn i {
            margin-right: 8px;
            color: var(--army-gold);
        }

        .contact-btn:hover {
            background: rgba(201, 161, 69, 0.3);
        }

        .contact-btn.primary {
            background: rgba(13, 77, 29, 0.5);
        }

        .contact-btn.primary:hover {
            background: rgba(13, 77, 29, 0.7);
        }

        .add-contact-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(0, 0, 0, 0.2);
            border: 2px dashed rgba(201, 161, 69, 0.3);
            border-radius: 12px;
            padding: 40px 30px;
            cursor: pointer;
            transition: all 0.3s;
            flex-direction: column;
            color: var(--army-gold);
            height: 100%;
            text-align: center;
        }

        .add-contact-btn:hover {
            border-color: var(--army-gold);
            background: rgba(201, 161, 69, 0.1);
        }

        .add-contact-btn i {
            font-size: 3rem;
            margin-bottom: 15px;
        }

        .add-contact-btn span {
            font-size: 1.3rem;
            font-weight: 500;
        }

        /* Map */
        .map-screen {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        #map-container {
            flex: 1;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid rgba(201, 161, 69, 0.3);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        .map-controls {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .map-btn {
            padding: 14px 22px;
            background: rgba(13, 77, 29, 0.5);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            font-weight: 500;
            transition: all 0.3s;
            border: 1px solid rgba(201, 161, 69, 0.2);
            font-size: 1.05rem;
        }

        .map-btn:hover {
            background: rgba(13, 77, 29, 0.7);
            transform: translateY(-3px);
        }

        .map-btn i {
            margin-right: 10px;
            color: var(--army-gold);
        }

        .map-info {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .map-stats {
            display: flex;
            gap: 15px;
        }

        .map-stat {
            padding: 12px 18px;
            background: rgba(0, 0, 0, 0.3);
            border-radius: 8px;
            border: 1px solid rgba(201, 161, 69, 0.2);
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .map-stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--army-gold);
        }

        .map-stat-label {
            font-size: 0.9rem;
            opacity: 0.8;
        }

        /* Settings */
        .settings-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }

        .settings-card {
            background: rgba(0, 0, 0, 0.3);
            border-radius: 12px;
            padding: 28px;
            border: 1px solid rgba(201, 161, 69, 0.2);
        }

        .settings-card h2 {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid rgba(201, 161, 69, 0.3);
            color: var(--army-gold);
            font-size: 1.6rem;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .settings-card h2 i {
            font-size: 1.4rem;
        }

        .setting-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 18px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .setting-item:last-child {
            border-bottom: none;
        }

        .setting-info {
            flex: 1;
        }

        .setting-info h3 {
            margin-bottom: 8px;
            color: var(--army-gold);
            font-size: 1.2rem;
        }

        .setting-info p {
            font-size: 0.95rem;
            opacity: 0.8;
            line-height: 1.5;
        }

        select {
            padding: 10px 15px;
            background: rgba(13, 77, 29, 0.5);
            color: white;
            border: 1px solid rgba(201, 161, 69, 0.3);
            border-radius: 8px;
            min-width: 180px;
            font-size: 1rem;
        }

        .privacy-content {
            line-height: 1.7;
            max-height: 400px;
            overflow-y: auto;
            padding-right: 15px;
            font-size: 1.05rem;
        }

        .privacy-content h3 {
            margin: 25px 0 15px;
            color: var(--army-gold);
            font-size: 1.3rem;
        }

        .privacy-content p {
            margin-bottom: 18px;
        }

        .privacy-content ul {
            padding-left: 25px;
            margin-bottom: 25px;
        }

        .privacy-content li {
            margin-bottom: 12px;
            display: flex;
            align-items: flex-start;
            line-height: 1.6;
        }

        .privacy-content li i {
            color: var(--army-gold);
            margin-right: 12px;
            margin-top: 6px;
            font-size: 1.1rem;
        }

        /* Footer */
        .app-footer {
            background: rgba(0, 0, 0, 0.8);
            padding: 15px;
            text-align: center;
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.7);
            border-top: 1px solid rgba(201, 161, 69, 0.2);
            margin-top: 30px;
            border-radius: 10px;
        }

        .developer-info {
            margin-top: 10px;
            font-weight: bold;
            color: var(--army-gold);
        }

        /* Full Screen Map */
        .full-screen-map {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1000;
            background: black;
        }

        .map-header {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            padding: 15px;
            background: rgba(10, 58, 23, 0.9);
            z-index: 1001;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .close-map {
            background: var(--danger-red);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 30px;
            cursor: pointer;
            font-weight: bold;
        }

        #full-map-container {
            width: 100%;
            height: 100%;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .main-content {
                grid-template-columns: 200px 1fr;
            }
            
            .settings-container {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 992px) {
            .main-content {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .contacts-container {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .app-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .logo-container {
                justify-content: center;
            }
            
            .map-controls {
                flex-direction: column;
            }
            
            .map-btn {
                width: 100%;
            }
            
            .map-info {
                flex-direction: column;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Login Screen -->
    <div id="login-screen" class="login-container">
        <div class="login-card">
            <div class="login-logo">
                <i class="fas fa-shield-alt"></i>
                <div class="login-title">Mission Rakshak</div>
                <div class="login-subtitle">Indian Soldier Survival Assistant</div>
            </div>
            
            <div class="login-form">
                <div class="form-group">
                    <label for="military-id">Military ID</label>
                    <input type="text" id="military-id" class="form-control" placeholder="Enter your Military ID">
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" class="form-control" placeholder="Enter your password">
                </div>
                
                <div class="form-group">
                    <label for="contact-no">Army Contact Number</label>
                    <input type="text" id="contact-no" class="form-control" placeholder="Enter contact number">
                </div>
                
                <button id="login-btn" class="login-btn">ACCESS SECURE SYSTEM</button>
            </div>
            
            <div class="app-footer">
                <p>Developed by ShivNet Defence Lab</p>
                <p>Secure Soldier Survival Assistant for Indian Defence Forces</p>
            </div>
        </div>
    </div>
    
    <!-- Main App (Initially Hidden) -->
    <div id="main-app">
        <!-- App Header -->
        <div class="app-header">
            <div class="logo-container">
                <div class="app-logo">
                    <i class="fas fa-shield-alt"></i>
                    <div>
                        <div class="app-title">Mission Rakshak</div>
                        <div class="app-tagline">Indian Soldier Survival Assistant</div>
                    </div>
                </div>
            </div>
            
            <button class="sos-btn">
                <i class="fas fa-bell"></i> SOS EMERGENCY
            </button>
            
            <div class="utility-icons">
                <button class="utility-btn" title="Notifications">
                    <i class="fas fa-bell"></i>
                </button>
                <button class="utility-btn" title="Change Language">
                    <i class="fas fa-language"></i>
                </button>
                <button class="utility-btn" title="Logout">
                    <i class="fas fa-sign-out-alt"></i>
                </button>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="main-content">
            <!-- Sidebar -->
            <div class="sidebar">
                <div class="user-info">
                    <div class="user-avatar">RV</div>
                    <div class="user-details">
                        <div class="user-name">Rajesh Verma</div>
                        <div class="user-role">Soldier ID: IND-ARMY-7284</div>
                    </div>
                </div>
                
                <div class="nav-links">
                    <div class="nav-item active" data-target="ai-assistant">
                        <i class="fas fa-robot"></i>
                        <span>AI Assistant</span>
                    </div>
                    <div class="nav-item" data-target="family-contact">
                        <i class="fas fa-users"></i>
                        <span>Family Contact</span>
                    </div>
                    <div class="nav-item" data-target="map">
                        <i class="fas fa-map-marked-alt"></i>
                        <span>Border Map</span>
                    </div>
                    <div class="nav-item" data-target="settings">
                        <i class="fas fa-cog"></i>
                        <span>Settings</span>
                    </div>
                    <div class="nav-item" data-target="survival-tips">
                        <i class="fas fa-book-medical"></i>
                        <span>Survival Guide</span>
                    </div>
                    <div class="nav-item" data-target="first-aid">
                        <i class="fas fa-first-aid"></i>
                        <span>First Aid</span>
                    </div>
                </div>
            </div>
            
            <!-- Content Area -->
            <div class="content-area">
                <!-- AI Assistant Screen -->
                <div class="content-header">
                    <div class="page-title">
                        <i class="fas fa-robot"></i>
                        AI Survival Assistant
                    </div>
                </div>
                
                <div class="screen ai-assistant active" id="ai-assistant">
                    <div class="chat-container" id="chat-container">
                        <div class="message ai-message">
                            <div class="message-content">
                                <strong>Mission Rakshak AI:</strong> Welcome, Soldier. I'm your AI survival assistant. How can I help you today?
                            </div>
                            <div class="message-time">Just now</div>
                        </div>
                        <div class="message ai-message">
                            <div class="message-content">
                                You can ask me about first aid, navigation, survival techniques, or any field-related questions in English, Hindi or Marathi. I work offline too!
                            </div>
                            <div class="message-time">Just now</div>
                        </div>
                    </div>
                    
                    <div class="input-container">
                        <input type="text" class="message-input" id="message-input" placeholder="Type your survival question in English, Hindi or Marathi...">
                        <button class="voice-btn" id="voice-btn" title="Voice Input">
                            <i class="fas fa-microphone"></i>
                        </button>
                        <button class="send-btn" id="send-btn" title="Ask AI">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </div>
                    
                    <div class="status-container">
                        <div class="connection-status online">
                            <i class="fas fa-wifi"></i> Online: Connected to AI Assistant
                        </div>
                        <div class="language-indicator">
                            <i class="fas fa-language"></i> Language: English, Hindi, Marathi
                        </div>
                    </div>
                </div>
                
                <!-- Family Contact Screen -->
                <div class="screen family-contact" id="family-contact">
                    <div class="contacts-container">
                        <div class="contact-card">
                            <div class="contact-header">
                                <div class="contact-avatar">PP</div>
                                <div class="contact-info">
                                    <h3>Priya Patil</h3>
                                    <p>Wife - Primary Contact</p>
                                </div>
                            </div>
                            <div class="contact-body">
                                <div class="contact-field">
                                    <i class="fas fa-phone"></i>
                                    <p>+91 98765 43210</p>
                                </div>
                                <div class="contact-field">
                                    <i class="fas fa-home"></i>
                                    <p>Pune, Maharashtra</p>
                                </div>
                                <div class="contact-field">
                                    <i class="fas fa-shield-alt"></i>
                                    <p>Last Contact: 2 hours ago</p>
                                </div>
                                <div class="contact-actions">
                                    <button class="contact-btn">
                                        <i class="fas fa-comment"></i> Message
                                    </button>
                                    <button class="contact-btn primary">
                                        <i class="fas fa-video"></i> Video Call
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="contact-card">
                            <div class="contact-header">
                                <div class="contact-avatar">SP</div>
                                <div class="contact-info">
                                    <h3>Sunil Patil</h3>
                                    <p>Father - Secondary Contact</p>
                                </div>
                            </div>
                            <div class="contact-body">
                                <div class="contact-field">
                                    <i class="fas fa-phone"></i>
                                    <p>+91 97654 32109</p>
                                </div>
                                <div class="contact-field">
                                    <i class="fas fa-home"></i>
                                    <p>Nashik, Maharashtra</p>
                                </div>
                                <div class="contact-field">
                                    <i class="fas fa-shield-alt"></i>
                                    <p>Last Contact: 1 day ago</p>
                                </div>
                                <div class="contact-actions">
                                    <button class="contact-btn">
                                        <i class="fas fa-comment"></i> Message
                                    </button>
                                    <button class="contact-btn primary">
                                        <i class="fas fa-video"></i> Video Call
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="contact-card">
                            <div class="add-contact-btn">
                                <i class="fas fa-plus-circle"></i>
                                <span>Add Emergency Contact</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Map Screen -->
                <div class="screen map-screen" id="map">
                    <div class="content-header">
                        <div class="page-title">
                            <i class="fas fa-map-marked-alt"></i>
                            Border Map & Navigation
                        </div>
                    </div>
                    
                    <div id="map-container"></div>
                    
                    <div class="map-controls">
                        <button class="map-btn" id="full-screen-map-btn">
                            <i class="fas fa-expand"></i> Full Screen Map
                        </button>
                        <button class="map-btn">
                            <i class="fas fa-shoe-prints"></i> Start Breadcrumb Trail
                        </button>
                        <button class="map-btn">
                            <i class="fas fa-location-arrow"></i> My Location
                        </button>
                        <button class="map-btn">
                            <i class="fas fa-download"></i> Download Offline Map
                        </button>
                        <button class="map-btn">
                            <i class="fas fa-ruler-combined"></i> Measure Distance
                        </button>
                        <button class="map-btn">
                            <i class="fas fa-exclamation-triangle"></i> Report Danger Zone
                        </button>
                    </div>
                    
                    <div class="map-info">
                        <div class="map-stats">
                            <div class="map-stat">
                                <div class="map-stat-value">15,106 km</div>
                                <div class="map-stat-label">Total Border Length</div>
                            </div>
                            <div class="map-stat">
                                <div class="map-stat-value">3.2 km</div>
                                <div class="map-stat-label">Distance to Unit</div>
                            </div>
                        </div>
                        
                        <div class="connection-status">
                            <i class="fas fa-map-marked-alt"></i> Offline Map: Border zones loaded
                        </div>
                    </div>
                </div>
                
                <!-- Settings Screen -->
                <div class="screen settings" id="settings">
                    <div class="content-header">
                        <div class="page-title">
                            <i class="fas fa-cog"></i>
                            Settings & Privacy
                        </div>
                    </div>
                    
                    <div class="settings-container">
                        <div class="settings-card">
                            <h2><i class="fas fa-sliders-h"></i> App Settings</h2>
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Theme</h3>
                                    <p>Switch between light and dark mode for better visibility</p>
                                </div>
                                <select id="theme-select">
                                    <option value="dark">Dark Mode (Default)</option>
                                    <option value="light">Light Mode</option>
                                    <option value="night">Night Vision</option>
                                </select>
                            </div>
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Language</h3>
                                    <p>Select your preferred language for the interface</p>
                                </div>
                                <select id="language-select">
                                    <option value="english">English</option>
                                    <option value="hindi">Hindi</option>
                                    <option value="marathi">Marathi</option>
                                    <option value="tamil">Tamil</option>
                                    <option value="punjabi">Punjabi</option>
                                </select>
                            </div>
                            <div class="setting-item">
                                <div class="setting-info">
                                    <h3>Font Size</h3>
                                    <p>Adjust text size for better readability</p>
                                </div>
                                <select id="font-size-select">
                                    <option value="small">Small</option>
                                    <option value="medium" selected>Medium</option>
                                    <option value="large">Large</option>
                                    <option value="xlarge">Extra Large</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="settings-card">
                            <h2><i class="fas fa-shield-alt"></i> Privacy & Security</h2>
                            <div class="privacy-content">
                                <h3>Mission Rakshak Privacy Policy</h3>
                                <p>Your security and privacy are our top priority. This app is designed with military-grade security protocols:</p>
                                
                                <ul>
                                    <li><i class="fas fa-ban"></i> <strong>No Ads:</strong> This app contains no advertisements</li>
                                    <li><i class="fas fa-user-secret"></i> <strong>No Tracking:</strong> We do not track your activities</li>
                                    <li><i class="fas fa-lock"></i> <strong>No Data Resale:</strong> Your data is never sold to third parties</li>
                                    <li><i class="fas fa-key"></i> <strong>End-to-End Encryption:</strong> All communications are encrypted</li>
                                    <li><i class="fas fa-database"></i> <strong>Offline-First:</strong> Your data remains on your device</li>
                                    <li><i class="fas fa-fire"></i> <strong>Firebase Security:</strong> Strict access rules and encrypted storage</li>
                                </ul>
                                
                                <h3>Firebase Security Implementation</h3>
                                <p>Our Firebase backend ensures maximum security:</p>
                                <ul>
                                    <li><i class="fas fa-user-tag"></i> Role-based access control (soldiers vs. admins)</li>
                                    <li><i class="fas fa-lock"></i> Encrypted Firestore storage for sensitive data</li>
                                    <li><i class="fas fa-ban"></i> Strict Firebase rules preventing unauthorized access</li>
                                    <li><i class="fas fa-sync"></i> Offline sync capabilities for low-connectivity areas</li>
                                    <li><i class="fas fa-map-marker-alt"></i> Location data only accessible during SOS activation</li>
                                </ul>
                                
                                <h3>Data Collection Policy</h3>
                                <p>We collect minimal data required for app functionality:</p>
                                <ul>
                                    <li><i class="fas fa-id-card"></i> Military ID for authentication</li>
                                    <li><i class="fas fa-address-book"></i> Emergency contact information (stored encrypted)</li>
                                    <li><i class="fas fa-map-pin"></i> Location data only when using SOS or navigation</li>
                                    <li><i class="fas fa-history"></i> Breadcrumb trail stored locally and encrypted</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- App Footer -->
        <div class="app-footer">
            <p>Mission Rakshak - Secure Soldier Survival Assistant | Developed for Indian Defence Forces</p>
            <p class="developer-info">Developed by ShivNet Defence Lab</p>
            <p>All data encrypted and secure | No third-party access</p>
        </div>
    </div>

    <!-- Full Screen Map (Hidden Initially) -->
    <div id="full-screen-map" class="full-screen-map" style="display: none;">
        <div class="map-header">
            <div class="app-title">Mission Rakshak - Full Screen Map</div>
            <button class="close-map" id="close-full-map">Close Map</button>
        </div>
        <div id="full-map-container"></div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Global map variable
        let map;
        let fullScreenMap;

        // Initialize map
        function initMap() {
            // Create map centered on India
            map = L.map('map-container', {
                zoomControl: false
            }).setView([22.3511, 78.6677], 5);
            
            // Add custom tile layer
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
            
            // Add border markers
            const borderPoints = [
                {lat: 34.1439, lng: 77.5767, title: "Siachen Glacier", type: "north"},
                {lat: 32.7667, lng: 78.9667, title: "Ladakh Border", type: "north"},
                {lat: 26.7606, lng: 92.1030, title: "Arunachal Border", type: "east"},
                {lat: 23.7333, lng: 92.7167, title: "Mizoram Border", type: "east"},
                {lat: 26.5000, lng: 90.5000, title: "Assam Border", type: "east"},
                {lat: 31.1471, lng: 74.8690, title: "Punjab Border", type: "west"},
                {lat: 26.2183, lng: 88.7332, title: "West Bengal Border", type: "east"},
                {lat: 8.0667, lng: 77.4667, title: "Kanyakumari", type: "south"}
            ];
            
            borderPoints.forEach(point => {
                const marker = L.marker([point.lat, point.lng]).addTo(map);
                marker.bindPopup(`
                    <div style="text-align:center;">
                        <b>${point.title}</b><br>
                        <small>Indian Border Zone</small><br>
                        <div style="margin-top:10px;color:${point.type==='north'?'#ff9800':point.type==='south'?'#4CAF50':point.type==='east'?'#2196F3':'#9C27B0'}">
                            <i class="fas fa-${point.type==='north'?'arrow-up':point.type==='south'?'arrow-down':point.type==='east'?'arrow-right':'arrow-left'}"></i> 
                            ${point.type.toUpperCase()}
                        </div>
                    </div>
                `);
            });
            
            // Add danger zones (admin only)
            const dangerZones = [
                {lat: 34.5000, lng: 76.5000, title: "High Alert Zone", desc: "Restricted area"},
                {lat: 32.2000, lng: 79.0000, title: "Recent Activity", desc: "Observed movement"},
                {lat: 26.0000, lng: 92.5000, title: "Sensitive Area", desc: "Exercise in progress"}
            ];
            
            dangerZones.forEach(zone => {
                L.circle([zone.lat, zone.lng], {
                    color: 'red',
                    fillColor: '#f03',
                    fillOpacity: 0.3,
                    radius: 15000
                }).addTo(map).bindPopup(`
                    <div style="color:red;">
                        <b>DANGER ZONE</b><br>
                        ${zone.title}<br>
                        <small>${zone.desc}</small>
                    </div>
                `);
            });
            
            // Add soldier positions
            const soldierPositions = [
                {lat: 34.0000, lng: 77.0000, name: "Unit Alpha", status: "On Patrol"},
                {lat: 32.5000, lng: 79.5000, name: "Unit Bravo", status: "Stationary"},
                {lat: 26.5000, lng: 92.0000, name: "Unit Charlie", status: "On Patrol"},
                {lat: 23.5000, lng: 92.5000, name: "Unit Delta", status: "Resting"}
            ];
            
            soldierPositions.forEach(pos => {
                const marker = L.marker([pos.lat, pos.lng], {
                    icon: L.divIcon({
                        className: 'soldier-marker',
                        html: `<div style="background: ${pos.status === 'On Patrol' ? '#ff9800' : '#4CAF50'}; 
                                width: 24px; height: 24px; border-radius: 50%; border: 2px solid white; display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-user" style="color:white; font-size:12px;"></i>
                               </div>`,
                        iconSize: [28, 28]
                    })
                }).addTo(map);
                
                marker.bindPopup(`
                    <div>
                        <b>${pos.name}</b><br>
                        Status: ${pos.status}<br>
                        <div style="margin-top:10px;">
                            <button class="map-btn" style="padding:5px 10px; font-size:0.9rem; width:100%;">
                                <i class="fas fa-ruler"></i> Measure Distance
                            </button>
                        </div>
                    </div>
                `);
            });
            
            // Add animal markers
            const animals = [
                {lat: 34.2000, lng: 77.3000, name: "Snow Leopard", danger: "High"},
                {lat: 26.3000, lng: 92.2000, name: "Indian Elephant", danger: "Medium"},
                {lat: 23.6000, lng: 92.4000, name: "King Cobra", danger: "Extreme"}
            ];
            
            animals.forEach(animal => {
                const marker = L.marker([animal.lat, animal.lng], {
                    icon: L.divIcon({
                        className: 'animal-marker',
                        html: `<div style="background: ${animal.danger==='Extreme'?'#f44336':animal.danger==='High'?'#ff9800':'#4CAF50'}; 
                                width: 28px; height: 28px; border-radius: 50%; border: 2px solid white; display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-paw" style="color:white; font-size:14px;"></i>
                               </div>`,
                        iconSize: [32, 32]
                    })
                }).addTo(map);
                
                marker.bindPopup(`
                    <div>
                        <b>${animal.name}</b><br>
                        Danger Level: <span style="color:${animal.danger==='Extreme'?'#f44336':animal.danger==='High'?'#ff9800':'#4CAF50'}">${animal.danger}</span><br>
                        <div style="margin-top:10px;">
                            <button class="map-btn" style="padding:5px 10px; font-size:0.9rem; width:100%;">
                                <i class="fas fa-info-circle"></i> Safety Information
                            </button>
                        </div>
                    </div>
                `);
            });
            
            // Add zoom control
            L.control.zoom({
                position: 'bottomright'
            }).addTo(map);
        }
        
        // Initialize full screen map
        function initFullScreenMap() {
            fullScreenMap = L.map('full-map-container', {
                zoomControl: true
            }).setView(map.getCenter(), map.getZoom());
            
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(fullScreenMap);
            
            // Copy existing markers and layers to full screen map
            map.eachLayer(function(layer) {
                if (layer instanceof L.Marker || layer instanceof L.Circle) {
                    layer.addTo(fullScreenMap);
                }
            });
        }

        // Initialize app when DOM is loaded
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize map
            initMap();
            
            // Login functionality
            document.getElementById('login-btn').addEventListener('click', function() {
                const militaryId = document.getElementById('military-id').value;
                const password = document.getElementById('password').value;
                const contactNo = document.getElementById('contact-no').value;
                
                if (militaryId && password && contactNo) {
                    document.getElementById('login-screen').style.display = 'none';
                    document.getElementById('main-app').style.display = 'block';
                } else {
                    alert('Please fill all fields');
                }
            });
            
            // Navigation functionality
            const navItems = document.querySelectorAll('.nav-item');
            const screens = document.querySelectorAll('.screen');
            
            navItems.forEach(item => {
                item.addEventListener('click', function() {
                    const target = this.getAttribute('data-target');
                    
                    // Update active nav item
                    navItems.forEach(nav => nav.classList.remove('active'));
                    this.classList.add('active');
                    
                    // Update page title
                    const titleMap = {
                        'ai-assistant': 'AI Survival Assistant',
                        'family-contact': 'Family Contact System',
                        'map': 'Border Map & Navigation',
                        'settings': 'Settings & Privacy',
                        'survival-tips': 'Survival Guide',
                        'first-aid': 'First Aid Procedures'
                    };
                    
                    const titleElement = document.querySelector('.page-title');
                    titleElement.innerHTML = `
                        <i class="fas fa-${this.querySelector('i').className.split(' ')[1]}"></i>
                        ${titleMap[target]}
                    `;
                    
                    // Show target screen
                    screens.forEach(screen => {
                        screen.classList.remove('active');
                        if (screen.id === target) {
                            screen.classList.add('active');
                        }
                    });
                });
            });
            
            // AI Assistant functionality
            const messageInput = document.getElementById('message-input');
            const sendBtn = document.getElementById('send-btn');
            const chatContainer = document.getElementById('chat-container');
            
            function addMessage(text, isUser) {
                const messageDiv = document.createElement('div');
                messageDiv.className = `message ${isUser ? 'user-message' : 'ai-message'}`;
                
                const now = new Date();
                const timeString = `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`;
                
                messageDiv.innerHTML = `
                    <div class="message-content">
                        ${isUser ? text : `<strong>Mission Rakshak AI:</strong> ${text}`}
                    </div>
                    <div class="message-time">${timeString}</div>
                `;
                
                chatContainer.appendChild(messageDiv);
                chatContainer.scrollTop = chatContainer.scrollHeight;
            }
            
            function getAIResponse(userMessage) {
                // Sample responses with Marathi translations
                const responses = {
                    'first aid': 'For immediate first aid:\n1. Ensure safety first\n2. Check responsiveness\n3. Control bleeding with direct pressure\n4. Treat for shock by keeping warm\n5. Seek medical help ASAP\n\n(प्रथमोपचार: सुरक्षितता तपासा, प्रतिसाद तपासा, रक्तस्त्राव नियंत्रित करा, शॉकसाठी उपचार करा, वैद्यकीय मदत घ्या)',
                    'snake bite': 'Snake bite procedure:\n1. Stay calm and immobilize the area\n2. Remove jewelry/tight clothing\n3. Keep bite below heart level\n4. Do NOT cut wound or attempt to suck venom\n5. Seek medical help immediately\n\n(सापाच्या चाव्यावर: शांत रहा, जागा हलवू नका, दागिने काढा, चावा हृदयापेक्षा खाली ठेवा, जखम कापू नका, लगेच डॉक्टरकडे जा)',
                    'navigation': 'Basic navigation:\n1. Use the sun (rises east, sets west)\n2. Stars: Pole Star (North) in Northern Hemisphere\n3. Natural indicators: moss on north side of trees\n4. Make a compass with needle and leaf\n5. Always carry a physical map as backup\n\n(नेव्हिगेशन: सूर्य, तारे, नैसर्गिक संकेत वापरा, कंपास बनवा, नकाशा ठेवा)',
                    'water': 'Water purification:\n1. Boiling: 10+ minutes at rolling boil\n2. Chemical: Iodine tablets (follow instructions)\n3. Filtration: Use cloth to remove large particles\n4. Solar: UV exposure in clear plastic bottle\n5. Avoid stagnant water when possible\n\n(पाणी शुद्धीकरण: उकळवा, आयोडीन गोळ्या, गाळणे, सोलर पद्धत, स्थिर पाणी टाळा)',
                    'shelter': 'Emergency shelter:\n1. Find natural cover like rock overhangs\n2. Build lean-to against tree or rock\n3. Insulate ground with leaves or pine needles\n4. Make roof with branches and foliage\n5. Ensure location is safe from elements and wildlife\n\n(आश्रय: नैसर्गिक आश्रय शोधा, लीन-टो बांधा, जमिनीवर पाने टाका, छप्पर बनवा, सुरक्षित स्थान निवडा)',
                    'border': 'Indian border length:\n1. Pakistan: 3,323 km\n2. China: 3,488 km\n3. Nepal: 1,751 km\n4. Bhutan: 699 km\n5. Myanmar: 1,643 km\n6. Bangladesh: 4,096 km\nTotal land border: 15,106.7 km\n\n(सीमा: पाकिस्तान ३,३२३ किमी, चीन ३,४८८ किमी, नेपाळ १,७५१ किमी, भूतान ६९९ किमी, म्यानमार १,६४३ किमी, बांग्लादेश ४,०९६ किमी, एकूण १५,१०६.७ किमी)',
                    'distance': 'Distance between soldiers:\nUse the map tool to measure distance between positions. In the field, estimate using:\n1. Pace counting\n2. Time estimation\n3. Visual markers\n4. GPS when available\n\n(अंतर: नकाशा वापरा, पावले मोजा, वेळेचा अंदाज घ्या, दृश्य चिन्हे वापरा, जीपीएस)',
                    'animal': 'Wild animal safety:\n1. Make noise while moving to avoid surprising animals\n2. Store food securely\n3. If you encounter a large animal, back away slowly\n4. For snakes, freeze then back away slowly\n5. Carry a whistle for emergencies\n\n(वन्य प्राणी सुरक्षा: आवाज करत चला, अन्न सुरक्षित ठेवा, मोठ्या प्राण्यापासून हळूहळू मागे हटा, साप दिसल्यास थांबा नंतर हळूहळू मागे हटा, शिटी वापरा)'
                };
                
                const lowerMsg = userMessage.toLowerCase();
                
                // Check for matches
                for (const [key, response] of Object.entries(responses)) {
                    if (lowerMsg.includes(key)) {
                        return response;
                    }
                }
                
                // Default response
                return "I'm here to help with survival situations. Try asking about first aid, navigation, water purification, or shelter building. For medical emergencies, use the SOS button immediately.\n\n(मी तुम्हाला सहाय्य करण्यासाठी इथे आहे. प्रथमोपचार, नेव्हिगेशन, पाणी शुद्धीकरण किंवा आश्रय बांधण्याबद्दल विचारा. आणीबाणी साठी SOS बटण वापरा.)";
            }
            
            sendBtn.addEventListener('click', function() {
                const message = messageInput.value.trim();
                if (message) {
                    addMessage(message, true);
                    messageInput.value = '';
                    
                    // Simulate AI response delay
                    setTimeout(() => {
                        const response = getAIResponse(message);
                        addMessage(response, false);
                    }, 1000);
                }
            });
            
            messageInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendBtn.click();
                }
            });
            
            // Voice button functionality
            const voiceBtn = document.getElementById('voice-btn');
            voiceBtn.addEventListener('click', function() {
                const languages = ["English", "Hindi", "Marathi"];
                const randomLang = languages[Math.floor(Math.random() * languages.length)];
                alert(`Voice input activated. Speak your question in ${randomLang}.\n\n(व्हॉइस इनपुट सुरू आहे. ${randomLang} मध्ये प्रश्न विचारा.)`);
            });
            
            // SOS button functionality
            const sosBtn = document.querySelector('.sos-btn');
            sosBtn.addEventListener('click', function() {
                if (confirm("ACTIVATE EMERGENCY SOS? This will alert your command center and emergency contacts.\n\n(आणीबाणी SOS सक्रिय करायचे? हे तुमच्या कमांड सेंटरला सूचित करेल.)")) {
                    // Simulate SOS activation
                    alert("EMERGENCY SOS ACTIVATED!\n\nHelp is on the way. Your location has been transmitted.\n\n(आणीबाणी SOS सक्रिय केले! मदत येत आहे. तुमचे स्थान पाठवले गेले आहे.)");
                    
                    // Add notification to chat
                    addMessage("EMERGENCY SOS ACTIVATED - Assistance requested", true);
                    
                    setTimeout(() => {
                        addMessage("SOS received. Command center alerted. Your location is being tracked. Hold position if safe. Help is en route.\n\n(SOS प्राप्त झाले. कमांड सेंटरला सूचना दिली. स्थान ट्रॅक केले जात आहे. सुरक्षित असेल तर तेथेच रहा. मदत येत आहे.)", false);
                    }, 1500);
                }
            });
            
            // Add contact button
            document.querySelector('.add-contact-btn').addEventListener('click', function() {
                alert("Secure contact form would appear. Only the soldier can add emergency contacts. Data would be encrypted in Firebase.\n\n(सुरक्षित संपर्क फॉर्म दिसेल. फक्त सैनिक आणीबाणी संपर्क जोडू शकतो. डेटा फायरबेसमध्ये एनक्रिप्ट केला जाईल.)");
            });
            
            // Full screen map functionality
            document.getElementById('full-screen-map-btn').addEventListener('click', function() {
                document.getElementById('full-screen-map').style.display = 'block';
                initFullScreenMap();
            });
            
            document.getElementById('close-full-map').addEventListener('click', function() {
                document.getElementById('full-screen-map').style.display = 'none';
                if (fullScreenMap) {
                    fullScreenMap.remove();
                }
            });
        });
    </script>
</body>
</html>
