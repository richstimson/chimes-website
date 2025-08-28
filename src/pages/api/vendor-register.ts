import type { APIRoute } from "astro";

export const POST: APIRoute = async ({ request }) => {
  try {
    const data = await request.formData();
    const email = data.get("email") as string;

    if (!email) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Email is required",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Please enter a valid email address",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Here you would typically save to a database or send to your email service
    // For now, we'll just log it and return success
    console.log(`Vendor interest registered: ${email}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Thank you! We'll be in touch soon.",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error processing vendor registration:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: "Something went wrong. Please try again.",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
};
