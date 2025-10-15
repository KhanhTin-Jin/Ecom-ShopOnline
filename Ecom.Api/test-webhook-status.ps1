# Test Webhook & Check Order Status Script
# Giúp debug payment webhook flow

param(
    [Parameter(Mandatory=$true)]
    [string]$OrderId,
    
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [string]$BaseUrl = "https://localhost:7188"
)

Write-Host "=== PAYMENT WEBHOOK DEBUG SCRIPT ===" -ForegroundColor Cyan
Write-Host ""

# Function to check order status
function Get-OrderStatus {
    param([string]$orderId, [string]$token)
    
    Write-Host "📋 Checking Order Status..." -ForegroundColor Yellow
    try {
        $headers = @{
            "Authorization" = "Bearer $token"
            "Accept" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/orders/$orderId" `
                                     -Method Get `
                                     -Headers $headers `
                                     -SkipCertificateCheck
        
        Write-Host "Order ID: $($response.Id)" -ForegroundColor Green
        Write-Host "Status: $($response.Status)" -ForegroundColor $(if ($response.Status -eq "paid") { "Green" } else { "Yellow" })
        Write-Host "Total Amount: ₫$($response.TotalAmount)" -ForegroundColor Green
        Write-Host "Created: $($response.CreatedAt)" -ForegroundColor Gray
        Write-Host ""
        
        return $response
    }
    catch {
        Write-Host "❌ Error checking order: $_" -ForegroundColor Red
        return $null
    }
}

# Function to check payment status
function Get-PaymentStatus {
    param([string]$orderId, [string]$token)
    
    Write-Host "💳 Checking Payment Status..." -ForegroundColor Yellow
    try {
        $headers = @{
            "Authorization" = "Bearer $token"
            "Accept" = "application/json"
        }
        
        # Query payments table directly via SQL or create a GET endpoint
        Write-Host "⚠️ Note: You need to check database directly or add GET /api/v1/payments/by-order/{orderId} endpoint" -ForegroundColor Yellow
        Write-Host ""
    }
    catch {
        Write-Host "❌ Error: $_" -ForegroundColor Red
    }
}

# Main flow
Write-Host "🔍 Step 1: Check initial order status" -ForegroundColor Cyan
$initialOrder = Get-OrderStatus -orderId $OrderId -token $Token

if ($null -eq $initialOrder) {
    Write-Host "❌ Cannot proceed - order not found" -ForegroundColor Red
    exit 1
}

if ($initialOrder.Status -ne "pending") {
    Write-Host "⚠️ Warning: Order is not in 'pending' status. Current: $($initialOrder.Status)" -ForegroundColor Yellow
}

Write-Host "✅ Initial check complete" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Instructions:" -ForegroundColor Cyan
Write-Host "1. Create payment: POST $BaseUrl/api/v1/payments/create" -ForegroundColor White
Write-Host "   Body: { `"orderId`": `"$OrderId`", `"provider`": `"stripe`" }" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Complete payment in Stripe checkout page" -ForegroundColor White
Write-Host ""
Write-Host "3. Re-run this script to check if status changed to 'paid'" -ForegroundColor White
Write-Host ""
Write-Host "4. Check logs in terminal for detailed webhook processing" -ForegroundColor White
Write-Host ""

# Option to monitor logs
$monitor = Read-Host "Do you want to continuously monitor order status? (y/n)"
if ($monitor -eq "y") {
    Write-Host ""
    Write-Host "🔄 Monitoring every 5 seconds (Ctrl+C to stop)..." -ForegroundColor Cyan
    Write-Host ""
    
    $previousStatus = $initialOrder.Status
    while ($true) {
        Start-Sleep -Seconds 5
        
        $currentOrder = Get-OrderStatus -orderId $OrderId -token $Token
        
        if ($null -ne $currentOrder -and $currentOrder.Status -ne $previousStatus) {
            Write-Host "🎉 STATUS CHANGED: $previousStatus → $($currentOrder.Status)" -ForegroundColor Green
            Write-Host ""
            
            if ($currentOrder.Status -eq "paid") {
                Write-Host "✅ Payment successful! Webhook processed correctly." -ForegroundColor Green
                break
            }
            
            $previousStatus = $currentOrder.Status
        }
    }
}
