import express from "express";
import multer from "multer";

const app = express();
const upload = multer({ limits: { fileSize: 8 * 1024 * 1024 } });

app.post("/analyze", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: "image required" });

    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return res.status(500).json({ error: "OPENAI_API_KEY is not configured" });

    const base64 = req.file.buffer.toString("base64");
    const mime = req.file.mimetype || "image/jpeg";

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "gpt-5.6-luna",
        input: [{
          role: "user",
          content: [
            {
              type: "input_text",
              text: `Analyze this meal photo for a food log. Identify visible foods and give approximate nutrition estimates.
Return ONLY valid JSON with this shape:
{
  "mealName": "short name",
  "foods": [{"name":"food","amount":"approx portion","calories":number,"protein":number,"fiber":number}],
  "estimatedCalories": number,
  "protein": number,
  "fiber": number,
  "note": "short uncertainty note"
}
Use null for nutrition values you cannot reasonably estimate. Do not claim precision from an image.`
            },
            {
              type: "input_image",
              image_url: `data:${mime};base64,${base64}`
            }
          ]
        }]
      })
    });

    if (!response.ok) {
      const text = await response.text();
      return res.status(response.status).send(text);
    }

    const data = await response.json();
    const outputText = data.output_text;
    const parsed = JSON.parse(outputText);
    res.json(parsed);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "analysis failed" });
  }
});

app.get("/health", (_, res) => res.json({ ok: true }));

app.listen(process.env.PORT || 8787, () => {
  console.log("plate backend running");
});
