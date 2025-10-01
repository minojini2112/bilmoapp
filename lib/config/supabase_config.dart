// Supabase Configuration
// Using direct values for now to avoid dotenv initialization issues

class SupabaseConfig {
  // Get these values from your Supabase project dashboard
  // Go to: https://supabase.com/dashboard -> Your Project -> Settings -> API
  
  static const String supabaseUrl = 'https://bibxfdoopgejnirfshsd.supabase.co';
  // Supabase project URL
  
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpYnhmZG9vcGdlam5pcmZzaHNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwMzk5NjAsImV4cCI6MjA3NDYxNTk2MH0.GpH65jFx1NlSlrliX9XrVbOCWWk_7c7gh-SBszqCJv0';
  // Supabase anon key
  
  // Service role key is NOT needed for client-side authentication
  // Only use it in secure backend services if needed
}

/*
SETUP INSTRUCTIONS:

1. Create a Supabase project:
   - Go to https://supabase.com
   - Sign up/Login
   - Click "New Project"
   - Choose organization and enter project details
   - Wait for project to be created

2. Get your project credentials:
   - Go to your project dashboard
   - Navigate to Settings -> API
   - Copy the "Project URL" and "anon public" key

3. Update the .env file:
   - Open Frontend/.env file
   - Replace 'https://your-project-id.supabase.co' with your Project URL
   - Replace 'your-anon-key-here' with your anon public key

4. Enable Authentication:
   - Go to Authentication -> Settings in your Supabase dashboard
   - Enable "Email" provider
   - Configure email templates if needed
   - Set up email confirmation settings

5. Optional - Set up Row Level Security (RLS):
   - Go to Authentication -> Policies
   - Create policies for your tables if needed

6. Test the setup:
   - Run the app
   - Try to sign up with a new email
   - Check your Supabase dashboard to see the new user

SECURITY NOTES:
- Never commit your .env file to version control
- The anon key is safe to use in client-side code
- Use .env.example as a template for other developers
- Environment variables are more secure than hardcoded values
*/
