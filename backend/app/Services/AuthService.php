<?php

namespace App\Services;

use App\Events\UserRegistered;
use App\Models\EmailVerification;
use App\Models\User;
use App\Notifications\EmailVerificationOtp;
use App\Notifications\PasswordResetOtp;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(
        protected UserRepositoryInterface $userRepository
    ) {
    }

    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $referredBy = null;

            if (! empty($data['referral_code'])) {
                $referrer = $this->userRepository->findByReferralCode($data['referral_code']);
                $referredBy = $referrer?->id;
            }

            $user = $this->userRepository->create([
                'first_name' => $data['first_name'],
                'last_name' => $data['last_name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'referral_code' => $this->generateReferralCode(),
                'referred_by' => $referredBy,
                'bvn' => $data['bvn'],
            ]);

            $this->sendEmailOtp($user);

            UserRegistered::dispatch($user);

            return ['user' => $user];
        });
    }

    public function login(string $login, string $password): array
    {
        $user = filter_var($login, FILTER_VALIDATE_EMAIL)
            ? $this->userRepository->findByEmail($login)
            : $this->userRepository->findByPhone($login);

        if (! $user || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['The provided credentials are incorrect.'],
            ]);
        }

        if ($user->status->value === 'suspended') {
            throw ValidationException::withMessages([
                'login' => ['Your account has been suspended. Contact support.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return ['user' => $user, 'token' => $token];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    public function sendEmailOtp(User $user): void
    {
        $otp = (string) random_int(100000, 999999);

        EmailVerification::query()->create([
            'email' => $user->email,
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
        ]);

        $user->notify(new EmailVerificationOtp($otp));
    }

    public function verifyEmail(string $email, string $otp): bool
    {
        $verification = EmailVerification::query()
            ->where('email', $email)
            ->where('otp', $otp)
            ->whereNull('verified_at')
            ->where('expires_at', '>', now())
            ->latest('id')
            ->first();

        if (! $verification) {
            throw ValidationException::withMessages([
                'otp' => ['This code is invalid or has expired.'],
            ]);
        }

        $verification->update(['verified_at' => now()]);

        $user = $this->userRepository->findByEmail($email);
        $user->forceFill(['email_verified_at' => now()])->save();

        return true;
    }

    public function forgotPassword(string $email): void
    {
        $user = $this->userRepository->findByEmail($email);

        if (! $user) {
            // Do not reveal whether the email exists.
            return;
        }

        $token = (string) random_int(100000, 999999);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            ['token' => Hash::make($token), 'created_at' => now()]
        );

        $user->notify(new PasswordResetOtp($token));
    }

    public function resetPassword(string $email, string $token, string $password): void
    {
        $record = DB::table('password_reset_tokens')->where('email', $email)->first();

        if (! $record || ! Hash::check($token, $record->token)) {
            throw ValidationException::withMessages([
                'token' => ['This reset code is invalid.'],
            ]);
        }

        if (now()->diffInMinutes($record->created_at) > 60) {
            throw ValidationException::withMessages([
                'token' => ['This reset code has expired.'],
            ]);
        }

        $user = $this->userRepository->findByEmail($email);
        $this->userRepository->update($user, ['password' => Hash::make($password)]);

        DB::table('password_reset_tokens')->where('email', $email)->delete();

        // Revoke all existing tokens for security.
        $user->tokens()->delete();
    }

    protected function generateReferralCode(): string
    {
        do {
            $code = Str::upper(Str::random(8));
        } while ($this->userRepository->findByReferralCode($code));

        return $code;
    }
}