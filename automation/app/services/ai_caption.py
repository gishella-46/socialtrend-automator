"""AI-powered caption generation with OpenAI integration."""

import os
import re
from typing import Any, Dict, List

from app.utils.logging import logger


class AICaptionService:
    """Service for AI-powered caption generation with OpenAI."""

    @staticmethod
    async def generate_caption(
        topic: str,
        trend: List[str] = None,
        style: str = "professional"
    ) -> Dict[str, Any]:
        """
        Generate caption and hashtags using OpenAI API.

        Args:
            topic: Main topic or subject
            trend: List of trending keywords or topics
            style: Caption style (professional, casual, creative)

        Returns:
            dict: Generated caption, hashtags, and recommended posting time
        """
        logger.info(
            "Generating AI caption",
            extra={
                "topic": topic,
                "style": style,
                "trend_count": len(trend) if trend else 0,
            }
        )

        try:
            # Check if OpenAI API key is available
            openai_key = os.getenv("OPENAI_API_KEY")

            if not openai_key:
                logger.warning("OPENAI_API_KEY not found, using fallback method")
                return AICaptionService._generate_fallback(topic, trend, style)

            # Use OpenAI API
            result = await AICaptionService._generate_with_openai(
                topic, trend, style, openai_key
            )

            logger.info(
                "AI caption generated successfully",
                extra={
                    "topic": topic,
                    "style": style,
                    "provider": "openai",
                }
            )

            return result

        except Exception as e:
            logger.error(
                "Failed to generate AI caption",
                extra={
                    "topic": topic,
                    "error": str(e),
                },
                exc_info=True
            )
            raise

    @staticmethod
    async def _generate_with_openai(
        topic: str,
        trend: List[str],
        style: str,
        api_key: str
    ) -> Dict[str, Any]:
        """Generate caption using OpenAI API."""
        try:
            from openai import OpenAI  # pylint: disable=import-outside-toplevel

            client = OpenAI(api_key=api_key)

            # Build prompt
            prompt = f"Generate a {style} social media caption"
            if topic:
                prompt += f" about: {topic}"
            if trend:
                prompt += f" incorporating these trends: {', '.join(trend[:5])}"
            prompt += "\n\nInclude relevant hashtags (10-15) and suggest the best time to post."

            # Call OpenAI API - Use GPT-4 (or gpt-3.5-turbo as fallback)
            model = "gpt-4"
            try:
                response = client.chat.completions.create(
                    model=model,
                    messages=[
                        {
                            "role": "system",
                            "content": (
                                "You are an expert social media content creator "
                                "specializing in viral, engaging captions."
                            )
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    max_tokens=300,
                    temperature=0.7
                )
            except Exception as model_error:  # pylint: disable=broad-except
                # Fallback to gpt-3.5-turbo if GPT-4 unavailable
                logger.warning(
                    "GPT-4 unavailable, trying gpt-3.5-turbo",
                    extra={"error": str(model_error)}
                )
                model = "gpt-3.5-turbo"
                response = client.chat.completions.create(
                    model=model,
                    messages=[
                        {
                            "role": "system",
                            "content": (
                                "You are an expert social media content creator "
                                "specializing in viral, engaging captions."
                            )
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    max_tokens=300,
                    temperature=0.7
                )

            # Parse response
            content = response.choices[0].message.content.strip()

            # Extract caption and hashtags
            caption, hashtags, recommended_time = AICaptionService._parse_response(content)

            return {
                "caption": caption,
                "hashtags": hashtags,
                "recommended_time": recommended_time,
                "provider": "openai",
                "model": model,
                "style": style,
            }

        except ImportError:
            logger.error("OpenAI library not installed, using fallback")
            return AICaptionService._generate_fallback(topic, trend, style)
        except Exception as e:
            logger.error(
                "OpenAI API error",
                extra={"error": str(e)}
            )
            raise

    @staticmethod
    def _parse_response(content: str) -> tuple:
        """
        Parse OpenAI response into caption, hashtags, and recommended time.

        Args:
            content: Raw response from OpenAI

        Returns:
            tuple: (caption, hashtags, recommended_time)
        """
        lines = content.split('\n')

        # Extract caption (first paragraph)
        caption_lines = []
        hashtags = []
        recommended_time = "09:00 AM"

        for line in lines:
            line = line.strip()
            if line.startswith('#'):
                hashtags.append(line)
            elif 'time' in line.lower() or 'post' in line.lower():
                # Try to extract time
                recommended_time = AICaptionService._extract_time(line)
            elif line and not line.startswith('Recommended'):
                caption_lines.append(line)

        caption = '\n\n'.join(caption_lines) if caption_lines else content

        # If no hashtags found, generate some
        if not hashtags:
            hashtags = [
                "#socialmedia", "#trending", "#viral",
                "#content", "#engagement", "#digital",
                "#marketing", "#creative", "#inspiration",
                "#community"
            ]

        return caption, hashtags[:15], recommended_time

    @staticmethod
    def _extract_time(text: str) -> str:
        """Extract recommended posting time from text."""
        # Simple time extraction
        time_pattern = r'\d{1,2}:\d{2}\s?(AM|PM|am|pm)'
        match = re.search(time_pattern, text)
        if match:
            return match.group(0)
        return "09:00 AM"

    @staticmethod
    def _generate_fallback(
        topic: str,
        trend: List[str],
        style: str
    ) -> Dict[str, Any]:
        """Fallback caption generation without OpenAI."""
        # Generate basic caption
        caption = f"Exciting news about {topic}!\n\n"
        if trend:
            caption += f"Trending topics: {', '.join(trend[:3])}\n\n"
        caption += "Share your thoughts below! 💭✨"

        # Generate hashtags
        hashtags = [
            f"#{topic.lower().replace(' ', '')}",
            "#trending",
            "#viral",
            "#socialmedia",
            "#content",
            "#engagement",
            "#digital",
            "#marketing",
            "#creative",
            "#inspiration"
        ]

        if trend:
            for t in trend[:5]:
                hashtag = f"#{t.lower().replace(' ', '')}"
                if hashtag not in hashtags:
                    hashtags.append(hashtag)

        return {
            "caption": caption,
            "hashtags": hashtags[:15],
            "recommended_time": "09:00 AM",
            "provider": "fallback",
            "style": style,
        }
