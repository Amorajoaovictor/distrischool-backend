-- Update admin password with BCrypt hash for password: admin123
UPDATE users 
SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMye/IVI0kqyqUJ/x8vFYMJqyqVi8/dRLaa'
WHERE id = 1;

-- Verify
SELECT id, email, substring(password, 1, 30) as password_start FROM users WHERE id = 1;
