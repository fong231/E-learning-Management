<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\ResourceController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\ProfileController; 
use App\Http\Controllers\Api\ProfileApiController; 

// --- Public ---
Route::get('/', function () { return redirect()->route('login'); })->name('home');

// Auth Pages
Route::get('/verify-email-success', function () { return view('auth.verify-email-success'); })->name('verify-email-success');
Route::get('/reset-password-success', function () { return view('auth.reset-password-success'); })->name('reset-password-success');
Route::get('/email-reset-password', function () { return view('auth.email-reset-password'); })->name('email-reset-password');
Route::get('/new-password-input', function () {
    return view('auth.new-password-input', ['token' => request('token'), 'email' => request('email')]);
})->name('new-password-input');

Route::middleware(['guest:api'])->group(function () {
    Route::get('/login', [AuthController::class, 'show'])->name('login');
});

// --- Protected Routes ---
Route::middleware(['auth:api'])->group(function () {
    
    // Dashboard
    Route::get('/dashboard', [ProjectController::class, 'dashboard'])->name('dashboard');

    // Projects
    Route::get('/projects/{project}', [ProjectController::class, 'show'])->name('projects.show');
    Route::post('/projects', [ProjectController::class, 'store'])->name('projects.store');
    Route::put('/projects/{project}', [ProjectController::class, 'update'])->name('projects.update');
    Route::delete('/projects/{project}', [ProjectController::class, 'destroy'])->name('projects.destroy');

    // Tasks
    Route::post('/tasks', [TaskController::class, 'store'])->name('tasks.store');

    // Profile 
    Route::get('/profile', [ProfileController::class, 'show'])->name('profile.show');
    Route::patch('/profile/update', [ProfileApiController::class, 'update'])->name('profile.update');
    Route::put('/profile/password', [ProfileApiController::class, 'updatePassword'])->name('profile.password');

    // Logout
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});
