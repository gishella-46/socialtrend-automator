# Testing Guide

Complete testing suite for SocialTrend Automator covering Laravel, FastAPI, and Vue.js.

## Laravel Tests (PHPUnit)

### Setup

```bash
cd backend
composer install
php artisan test
```

### Test Structure

```
backend/
├── tests/
│   ├── Feature/
│   │   ├── AuthTest.php        # Authentication tests
│   │   ├── TrendsTest.php      # Trends API tests
│   │   └── ScheduleTest.php    # Schedule tests
│   └── TestCase.php            # Base test case
├── database/
│   └── factories/
│       ├── UserFactory.php
│       ├── TrendFactory.php
│       └── SocialAccountFactory.php
└── phpunit.xml                 # PHPUnit configuration
```

### Running Tests

```bash
# All tests
php artisan test

# Specific test
php artisan test --filter AuthTest

# With coverage
php artisan test --coverage
```

### Available Tests

#### Authentication Tests
- `test_user_can_register_with_valid_data` - User registration flow
- `test_user_cannot_register_with_duplicate_email` - Duplicate email validation
- `test_user_can_login_with_valid_credentials` - Login success
- `test_user_cannot_login_with_invalid_credentials` - Login failure
- `test_authenticated_user_can_access_protected_route` - Auth middleware
- `test_unauthenticated_user_cannot_access_protected_route` - Unauthorized access

#### Trends Tests
- `test_authenticated_user_can_fetch_trends` - Fetch trends endpoint
- `test_unauthorized_user_cannot_fetch_trends` - Auth requirement
- `test_trends_are_paginated` - Pagination functionality

#### Schedule Tests
- `test_authenticated_user_can_schedule_post` - Schedule creation
- `test_user_cannot_schedule_past_date` - Date validation
- `test_unauthorized_user_cannot_schedule_post` - Auth requirement
- `test_scheduled_post_requires_valid_social_account` - Foreign key validation

## FastAPI Tests (PyTest)

### Setup

```bash
cd automation
pip install -r requirements.txt
pytest
```

### Test Structure

```
automation/
├── tests/
│   ├── conftest.py            # Pytest configuration
│   ├── test_health.py         # Health check tests
│   ├── test_upload.py         # Upload endpoint tests
│   ├── test_trends.py         # Trends endpoint tests
│   └── test_ai_caption.py     # AI caption tests
└── requirements.txt           # Includes pytest dependencies
```

### Running Tests

```bash
# All tests
pytest

# Specific test file
pytest tests/test_upload.py

# With verbosity
pytest -v

# With coverage
pytest --cov=app --cov-report=html
```

### Available Tests

#### Health Check Tests
- `test_health_check` - Health endpoint response
- `test_root_endpoint` - Root endpoint info

#### Upload Tests
- `test_upload_endpoint_requires_authentication` - Auth requirement
- `test_upload_endpoint_validates_platform` - Platform validation
- `test_upload_endpoint_with_valid_data` - Successful upload

#### Trends Tests
- `test_fetch_trends_requires_authentication` - Auth requirement
- `test_fetch_trends_validates_keywords` - Keyword validation
- `test_fetch_trends_with_valid_keywords` - Successful fetch

#### AI Caption Tests
- `test_ai_caption_requires_authentication` - Auth requirement
- `test_ai_caption_validates_input` - Input validation
- `test_ai_caption_with_valid_data` - Successful generation

## Vue.js Tests (Vitest)

### Setup

```bash
cd frontend
npm install
npm test
```

### Test Structure

```
frontend/
├── src/
│   ├── test/
│   │   └── setup.js            # Vitest configuration
│   └── components/
│       └── __tests__/
│           ├── Navbar.test.js
│           └── UploadCard.test.js
├── vite.config.js              # Vitest config included
└── package.json                # Test scripts
```

### Running Tests

```bash
# All tests
npm test

# Watch mode
npm test -- --watch

# UI mode
npm run test:ui

# Coverage
npm run test:coverage
```

### Available Tests

#### Component Tests
- `Navbar.test.js` - Navigation bar rendering
- `UploadCard.test.js` - Upload form components

## CI/CD Integration

Tests run automatically in GitHub Actions:

```yaml
# Laravel
- name: Run PHPUnit tests
  run: php artisan test

# FastAPI  
- name: Run PyTest tests
  run: pytest --tb=short -v

# Vue.js
- name: Run Vitest tests
  run: npm test -- --run
```

## Testing Best Practices

### Laravel
- Use factories for test data
- Use `RefreshDatabase` trait for database tests
- Test authentication flows thoroughly
- Validate API responses with `assertJsonStructure()`

### FastAPI
- Mock external API calls
- Test both success and failure cases
- Validate response status codes
- Use fixtures for common test setup

### Vue.js
- Test component rendering
- Test user interactions
- Use `@vue/test-utils` for mounting components
- Mock API calls with Vitest's mocking capabilities

## Coverage Goals

- **Backend**: >80% coverage
- **Automation**: >70% coverage
- **Frontend**: >60% coverage

## Troubleshooting

### Laravel Tests Failing
```bash
# Clear config cache
php artisan config:clear

# Re-run migrations
php artisan migrate:fresh
```

### FastAPI Tests Failing
```bash
# Reinstall dependencies
pip install -r requirements.txt

# Check Python version
python --version  # Should be 3.11+
```

### Vue Tests Failing
```bash
# Reinstall dependencies
npm ci

# Clear cache
rm -rf node_modules/.vite
```

## Next Steps

1. Add integration tests for cross-service communication
2. Add E2E tests with Playwright
3. Increase test coverage to 90%+
4. Add performance testing
5. Add load testing for critical endpoints

