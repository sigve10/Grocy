// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
            "authorization, x-client-info, apikey, content-type",
    };

    // Handle preflight requests
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    const { ean } = await req.json();

    const supabase = createClient(
        Deno.env.get("SUPABASE_URL") ?? "",
        Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );

    const { data, error } = await supabase.from("products").select("*").eq(
        "ean",
        ean,
    ).single();

    const response = (error || (data == null))
        ? await fetchFromKassalapp(ean, corsHeaders)
        : makeResponse(data, corsHeaders);

    return response;
});

const makeResponse = (product: object, corsHeaders: object) => {
    return new Response(
        JSON.stringify(product),
        {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
    );
};

const fetchFromKassalapp = async (ean: string, corsHeaders: object) => {
    const token = Deno.env.get("KASSAL_API");

    if (!token) {
        console.error("Missing API token");
        return new Response(
            JSON.stringify({ error: "Missing API token" }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }

    console.log("Calling Kassal with token:", token, "and EAN:", ean);

    try {
        const response = await fetch(
            `https://kassal.app/api/v1/products/ean/${ean}`,
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            },
        );

        console.log("Kassal response status:", response.status);

        const kassal_response = await response.json();
        console.log("Kassal API response:", kassal_response);

        if (
            !kassal_response.data?.products ||
            kassal_response.data.products.length === 0
        ) {
            console.warn("No products found for EAN:", ean);
            return new Response(
                JSON.stringify({ error: "No products found" }),
                {
                    status: 404,
                    headers: {
                        ...corsHeaders,
                        "Content-Type": "application/json",
                    },
                },
            );
        }

        const first_product = kassal_response.data.products[0];

        const parsed_product = {
            ean,
            name: first_product.name,
            description: first_product.description,
            imageurl: first_product.image,
        };

        console.log("Parsed product:", parsed_product);
        return makeResponse(parsed_product, corsHeaders);
    } catch (err) {
        console.error("Error fetching from Kassal:", err);
        return new Response(
            JSON.stringify({ error: "Internal server error" }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
};

/* To invoke locally:

  1. Run `npx supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Run `npx supabase functions serve --env-file <env_file>`
  2. Make an HTTP request:

  curl -L -X POST "http://127.0.0.1:54321/functions/v1/fetch-product" -H "Content-Type: application/json" -d '{"ean": "5060466516304"}'
  curl -L -X POST  'https://rmjqrlqmzuvmfutfvipl.supabase.co/functions/v1/fetch-product/5060466516304' \ --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' -d '{"ean": "5060466516304"}

*/
