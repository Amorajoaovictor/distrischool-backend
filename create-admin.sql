-- Create admin user with BCrypt hash for password: admin123
-- BCrypt hash: $2a$10$N9qo8uLOickgx2ZMRZoMye/IVI0kqyqUJ/x8vFYMJqyqVi8/dRLaa

INSERT INTO users (email, password, full_name, enabled, created_at, updated_at) 
VALUES (
    'admin@distrischool.com', 
    '$2a$10$N9qo8uLOickgx2ZMRZoMye/IVI0kqyqUJ/x8vFYMJqyqVi8/dRLaa', 
    'Admin Principal', 
    true, 
    NOW(), 
    NOW()
) 
RETURNING id;

-- Associate with ROLE_ADMIN (id=3)
-- Will need to replace {user_id} with the id returned above
