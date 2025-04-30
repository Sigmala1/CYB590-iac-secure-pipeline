<?php
// Simple Hello World PHP application
header('Content-Type: text/html');
?>
<!DOCTYPE html>
<html>
<head>
    <title>Hello World PHP Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f4f4f4;
        }
        .container {
            text-align: center;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello World!</h1>
        <p>Successfully deployed PHP application with Terraform to ECS.</p>
        <p>Environment: Development</p>
        <p>Server Time: <?php echo date('Y-m-d H:i:s'); ?></p>
    </div>
</body>
</html>
