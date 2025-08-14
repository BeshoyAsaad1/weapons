"""
Example API Views demonstrating Emirates timezone usage

These examples show how to properly handle timezone in your API responses.
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
from django.http import JsonResponse
from weaponpowercloud_backend.utils.emirates_timezone import (
    now_emirates, 
    format_emirates_datetime,
    convert_to_emirates
)
from weaponpowercloud_backend.utils.emirates_decorators import emirates_timezone_required


@api_view(['GET'])
@permission_classes([IsAuthenticated])
@emirates_timezone_required
def get_current_time_emirates(request):
    """
    API endpoint that returns current time in Emirates timezone.
    
    Returns:
        JSON response with current Emirates time in multiple formats
    """
    current_time = now_emirates()
    
    return Response({
        'current_time_emirates': current_time.isoformat(),
        'formatted_time': format_emirates_datetime(current_time),
        'date': current_time.date().isoformat(),
        'time': current_time.time().isoformat(),
        'timezone': str(current_time.tzinfo),
        'offset': str(current_time.utcoffset()),
        'timestamp': current_time.timestamp(),
    }, status=status.HTTP_200_OK)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_server_timezone_info(request):
    """
    API endpoint that provides comprehensive timezone information.
    Useful for debugging and verification.
    """
    utc_time = timezone.now()
    local_time = timezone.localtime(utc_time)
    emirates_time = convert_to_emirates(utc_time)
    
    return Response({
        'server_info': {
            'utc_time': utc_time.isoformat(),
            'local_time': local_time.isoformat(),
            'emirates_time': emirates_time.isoformat(),
            'active_timezone': str(timezone.get_current_timezone()),
        },
        'timezone_details': {
            'emirates_offset': str(emirates_time.utcoffset()),
            'is_dst': emirates_time.dst() is not None,
            'timezone_name': 'Asia/Dubai',
        },
        'formatting_examples': {
            'iso_format': emirates_time.isoformat(),
            'readable_format': format_emirates_datetime(emirates_time, '%A, %B %d, %Y at %I:%M %p %Z'),
            'short_format': format_emirates_datetime(emirates_time, '%Y-%m-%d %H:%M'),
        }
    }, status=status.HTTP_200_OK)


# Example of how to handle timezone in model serialization
class TimezoneAwareModelMixin:
    """
    Mixin for models that need Emirates timezone handling.
    
    Add this to your model serializers to ensure all datetime fields
    are properly converted to Emirates timezone.
    """
    
    def to_representation(self, instance):
        """Override to convert datetime fields to Emirates timezone."""
        data = super().to_representation(instance)
        
        # Convert datetime fields to Emirates timezone
        datetime_fields = [
            'created_at', 'updated_at', 'date_joined', 
            'last_login', 'published_at', 'modified_at'
        ]
        
        for field_name in datetime_fields:
            if field_name in data and data[field_name]:
                try:
                    # Parse the datetime if it's a string
                    if isinstance(data[field_name], str):
                        from dateutil import parser
                        dt = parser.parse(data[field_name])
                    else:
                        dt = data[field_name]
                    
                    # Convert to Emirates timezone
                    emirates_dt = convert_to_emirates(dt)
                    data[field_name] = emirates_dt.isoformat()
                    
                except (ValueError, TypeError):
                    # If conversion fails, keep original value
                    pass
        
        return data


# Example usage in your existing views
def example_news_view_with_timezone(request):
    """
    Example showing how to modify your existing news views
    to properly handle Emirates timezone.
    """
    from news_service.models import NewsItem
    from django.core.paginator import Paginator
    
    # All datetime operations will use Emirates timezone due to middleware
    news_items = NewsItem.objects.all().order_by('-created_at')
    
    # Format timestamps for response
    news_data = []
    for item in news_items[:10]:  # Limit for example
        news_data.append({
            'id': item.id,
            'title': item.title,
            'created_at': format_emirates_datetime(item.created_at),
            'created_at_iso': convert_to_emirates(item.created_at).isoformat(),
        })
    
    return JsonResponse({
        'news': news_data,
        'server_time': format_emirates_datetime(now_emirates()),
        'timezone': 'Asia/Dubai'
    })
