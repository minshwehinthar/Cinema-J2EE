<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: #fef2f2;
        }
        
        .order-status-completed {
            background-color: #dcfce7;
            color: #166534;
        }
        
        .order-status-pending {
            background-color: #fef3c7;
            color: #92400e;
        }
        
        .order-status-cancelled {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .card-shadow {
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
        }
        
        .hover-lift {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .hover-lift:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .red-theme {
            --color-primary: #dc2626;
            --color-primary-light: #fecaca;
            --color-primary-dark: #991b1b;
        }
        
        .bg-red-theme {
            background-color: #dc2626;
        }
        
        .text-red-theme {
            color: #dc2626;
        }
        
        .border-red-theme {
            border-color: #dc2626;
        }
    </style>
</head>
<body class="red-theme bg-gray-50">
<div class="flex min-h-screen">
    <!-- Sidebar -->
    <jsp:include page="layout/sidebar.jsp"/>

    <!-- Main content -->
    <div class="flex-1 sm:ml-64">
        <!-- Admin Header -->
        <jsp:include page="layout/AdminHeader.jsp"/>

        <div class="">
             <main class="min-h-screen">
        <div class="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Breadcrumb -->
            <nav class="flex text-sm text-gray-600 mb-6" aria-label="Breadcrumb">
                <ol class="flex items-center space-x-2">
                    <li>
                        <a href="index.jsp" class="hover:text-red-600 hover:underline">Home</a>
                    </li>
                    <li class="flex items-center">
                        <i class="fas fa-chevron-right text-xs mx-2"></i>
                    </li>
                    <li>
                        <a href="pendingOrders.jsp" class="hover:text-red-600 hover:underline">Orders</a>
                    </li>
                    <li class="flex items-center">
                        <i class="fas fa-chevron-right text-xs mx-2"></i>
                    </li>
                    <li class="text-red-600 font-medium">Order #ORD-2023-0012</li>
                </ol>
            </nav>

            <!-- Page Header -->
            <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
                <div>
                    <h1 class="text-2xl font-bold text-gray-900">Order Details</h1>
                    <p class="mt-1 text-gray-600">Order placed on October 15, 2023 at 2:30 PM</p>
                </div>
                <div class="mt-4 md:mt-0 flex space-x-3">
                    <button class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 flex items-center">
                        <i class="fas fa-print mr-2"></i>
                        <span>Print</span>
                    </button>
                    <button class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 flex items-center">
                        <i class="fas fa-arrow-left mr-2"></i>
                        <span>Back to Orders</span>
                    </button>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Left Column: Customer & Theater Info -->
                <div class="flex flex-col gap-6">
                    <!-- Customer Info Card -->
                    <div class="bg-white rounded-xl card-shadow p-6 hover-lift">
                        <div class="flex items-center mb-4">
                            <div class="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center text-red-600">
                                <i class="fas fa-user"></i>
                            </div>
                            <h2 class="text-xl font-semibold ml-3 text-gray-800">Customer Info</h2>
                        </div>
                        <div class="space-y-3">
                            <div class="flex items-start">
                                <i class="fas fa-user text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Name</p>
                                    <p class="font-medium text-gray-800">John Smith</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-envelope text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Email</p>
                                    <p class="font-medium text-gray-800">john.smith@example.com</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-phone text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Phone</p>
                                    <p class="font-medium text-gray-800">(555) 123-4567</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Theater Info Card -->
                    <div class="bg-white rounded-xl card-shadow p-6 hover-lift">
                        <div class="flex items-center mb-4">
                            <div class="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center text-red-600">
                                <i class="fas fa-building"></i>
                            </div>
                            <h2 class="text-xl font-semibold ml-3 text-gray-800">Theater Info</h2>
                        </div>
                        <div class="space-y-3">
                            <div class="flex items-start">
                                <i class="fas fa-film text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Name</p>
                                    <p class="font-medium text-gray-800">Grand Cinema</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-map-marker-alt text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Location</p>
                                    <p class="font-medium text-gray-800">123 Main Street, New York, NY</p>
                                </div>
                            </div>
                            <div class="flex items-start">
                                <i class="fas fa-phone text-gray-400 mt-1 mr-3 w-5"></i>
                                <div>
                                    <p class="text-sm text-gray-500">Contact</p>
                                    <p class="font-medium text-gray-800">(555) 987-6543</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Order Summary Card -->
                    <div class="bg-white rounded-xl card-shadow p-6 hover-lift">
                        <h2 class="text-xl font-semibold mb-4 text-gray-800">Order Summary</h2>
                        <div class="space-y-4">
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Order ID:</span>
                                <span class="font-medium text-red-600">ORD-2023-0012</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Order Date:</span>
                                <span class="font-medium text-gray-800">Oct 15, 2023</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Order Time:</span>
                                <span class="font-medium text-gray-800">2:30 PM</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-600">Payment Method:</span>
                                <span class="font-medium text-gray-800">Credit Card</span>
                            </div>
                            <div class="flex justify-between items-center pt-4 border-t border-gray-200">
                                <span class="text-lg font-semibold text-gray-800">Total Amount:</span>
                                <span class="text-xl font-bold text-red-600">$42.50</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Order Items -->
                <div class="lg:col-span-2 bg-white rounded-xl card-shadow p-6 hover-lift">
                    <div class="flex items-center justify-between mb-6">
                        <h2 class="text-xl font-semibold text-gray-800">Order Items</h2>
                        <div class="flex items-center">
                            <span class="text-gray-600 mr-2">Status:</span>
                            <span class="px-3 py-1 rounded-full text-sm font-semibold order-status-completed">Completed</span>
                        </div>
                    </div>

                    <!-- Order Items List -->
                    <div class="divide-y divide-gray-200">
                        <!-- Item 1 -->
                        <div class="flex items-center py-4">
                            <div class="flex-shrink-0 h-16 w-16 rounded-lg overflow-hidden">
                                <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80" alt="Cheeseburger" class="h-full w-full object-cover">
                            </div>
                            <div class="ml-4 flex-1">
                                <h3 class="font-medium text-gray-900">Cheeseburger</h3>
                                <p class="text-sm text-gray-500 mt-1">Delicious beef patty with cheese</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="text-right">
                                    <span class="font-medium text-gray-900">$8.99</span>
                                    <p class="text-sm text-gray-500">Qty: 1</p>
                                </div>
                            </div>
                        </div>

                        <!-- Item 2 -->
                        <div class="flex items-center py-4">
                            <div class="flex-shrink-0 h-16 w-16 rounded-lg overflow-hidden">
                                <img src="https://images.unsplash.com/photo-1571091718767-18b5b1457add?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80" alt="French Fries" class="h-full w-full object-cover">
                            </div>
                            <div class="ml-4 flex-1">
                                <h3 class="font-medium text-gray-900">French Fries</h3>
                                <p class="text-sm text-gray-500 mt-1">Crispy golden fries</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="text-right">
                                    <span class="font-medium text-gray-900">$4.50</span>
                                    <p class="text-sm text-gray-500">Qty: 1</p>
                                </div>
                            </div>
                        </div>

                        <!-- Item 3 -->
                        <div class="flex items-center py-4">
                            <div class="flex-shrink-0 h-16 w-16 rounded-lg overflow-hidden">
                                <img src="https://images.unsplash.com/photo-1626074353765-517a681e40be?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80" alt="Soft Drink" class="h-full w-full object-cover">
                            </div>
                            <div class="ml-4 flex-1">
                                <h3 class="font-medium text-gray-900">Soft Drink</h3>
                                <p class="text-sm text-gray-500 mt-1">Refreshing cola beverage</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="text-right">
                                    <span class="font-medium text-gray-900">$3.50</span>
                                    <p class="text-sm text-gray-500">Qty: 2</p>
                                </div>
                            </div>
                        </div>

                        <!-- Item 4 -->
                        <div class="flex items-center py-4">
                            <div class="flex-shrink-0 h-16 w-16 rounded-lg overflow-hidden">
                                <img src="https://images.unsplash.com/photo-1555507036-ab794f27d2e9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=80" alt="Popcorn" class="h-full w-full object-cover">
                            </div>
                            <div class="ml-4 flex-1">
                                <h3 class="font-medium text-gray-900">Popcorn</h3>
                                <p class="text-sm text-gray-500 mt-1">Large buttery popcorn</p>
                            </div>
                            <div class="flex items-center space-x-4">
                                <div class="text-right">
                                    <span class="font-medium text-gray-900">$7.99</span>
                                    <p class="text-sm text-gray-500">Qty: 1</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Order Total -->
                    <div class="mt-8 pt-6 border-t border-gray-200">
                        <div class="space-y-3">
                            <div class="flex justify-between">
                                <span class="text-gray-600">Subtotal</span>
                                <span class="text-gray-900">$38.97</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-gray-600">Tax</span>
                                <span class="text-gray-900">$3.53</span>
                            </div>
                            <div class="flex justify-between pt-3 border-t border-gray-200">
                                <span class="text-lg font-semibold text-gray-900">Total</span>
                                <span class="text-xl font-bold text-red-600">$42.50</span>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="mt-8 flex flex-wrap gap-3">
                        <button class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 flex items-center">
                            <i class="fas fa-check mr-2"></i>
                            <span>Mark as Completed</span>
                        </button>
                        <button class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 flex items-center">
                            <i class="fas fa-edit mr-2"></i>
                            <span>Edit Order</span>
                        </button>
                        <button class="px-4 py-2 bg-red-800 text-white rounded-lg hover:bg-red-900 flex items-center">
                            <i class="fas fa-times mr-2"></i>
                            <span>Cancel Order</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </main>
        </div>
    </div>
</div>
    <!-- Main Content Only -->
   
</body>
</html>