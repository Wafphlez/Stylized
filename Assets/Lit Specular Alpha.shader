Shader "Toon/Lit Specular Alpha" {
    Properties{
        _Color("Main Color", Color) = (1,1,1,1)
        _SColor("Specular Color", Color) = (1,1,1,1)
        _MainTex("Base (RGB)", 2D) = "white" {}
    _Ramp("Toon Ramp (RGB)", 2D) = "gray" {}
    _RampS("Specular Ramp (RGB)", 2D) = "gray" {} // specular ramp, cutoff point
    _SpecSize("Specular Size", Range(0.65,0.999)) = 0.9 // specular size
        _SpecOffset("Specular Offset", Range(0.5,1)) = 0.5 // specular offset of the spec Ramp
        _TColor("Gradient Overlay Top Color", Color) = (1,1,1,1)
        _BottomColor("Gradient Overlay Bottom Color", Color) = (0.23,0,0.95,1)
        _Offset("Gradient Offset", Range(-4,4)) = 3.2
        [Toggle(RIM)] _RIM("Fresnel Rim?", Float) = 0
        _RimColor("Fresnel Rim Color", Color) = (0.49,0.94,0.64,1)
        [Toggle(FADE)] _FADE("Fade specular to bottom?", Float) = 0
        _TopBottomOffset("Specular Fade Offset", Range(-4,4)) = 3.2
    }

        SubShader{
        Tags{ "Queue" = "Transparent"}
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
#pragma surface surf ToonRamp vertex:vert keepalpha
#pragma shader_feature FADE // fade toggle
#pragma shader_feature RIM // rim fresnel toggle
        sampler2D _Ramp;

    // custom lighting function that uses a texture ramp based
    // on angle between light direction and normal
#pragma lighting ToonRamp exclude_path:prepass
    inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten)
    {
#ifndef USING_DIRECTIONAL_LIGHT
        lightDir = normalize(lightDir);
#endif

        half d = dot(s.Normal, lightDir) * 0.5 + 0.5;
        half3 ramp = tex2D(_Ramp, float2(d,d)).rgb;

        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
        c.a = s.Alpha;
        return c;
    }


    sampler2D _MainTex;
    float4 _Color;
    float4 _SColor; // specular color
    sampler2D _RampS; // specular ramp
    float _SpecSize; // specular size
    float _SpecOffset; // offset specular ramp
    float4 _TColor; // top gradient color
    float4 _BottomColor;// bottom gradient color
    float _TopBottomOffset; // gradient bottom offset
    float _Offset; // specular fade offset
    float4 _RimColor; // fresnel rim color

    struct Input {
        float2 uv_MainTex : TEXCOORD0;
        float3 lightDir;
        float3 worldPos; // world position
        float3 viewDir; // view direction from camera
    };

    void vert(inout appdata_full v, out Input o)
    {
        UNITY_INITIALIZE_OUTPUT(Input, o);
        o.lightDir = WorldSpaceLightDir(v.vertex); // get the worldspace lighting direction
    }

    void surf(Input IN, inout SurfaceOutput o) {
        float3 localPos = (IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz);// local position of the object, with an offset
        half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        half d = dot(o.Normal, IN.lightDir) * 0.5 + _SpecOffset; // basing on normal and light direction
        half3 rampS = tex2D(_RampS, float2(d, d)).rgb; // specular ramp

        float rim = 1 - saturate(dot(IN.viewDir, o.Normal)); // calculate fresnel rim
#if RIM
        o.Emission = _RimColor.rgb * pow(rim, 1.5); // fresnel rim
#endif
        float specular = (step(_SpecSize, rampS.r)) * rampS * d * _SColor;
        o.Albedo = specular; // specular
        o.Alpha = c.a + specular;
#if FADE
        float specular2 = (step(_SpecSize, rampS.r)) * rampS * d * saturate(localPos.y + _TopBottomOffset) * _SColor;
        o.Albedo = specular2; // fade specular to bottom
        o.Alpha = c.a + specular2;
#endif
        o.Albedo += c.rgb * lerp(_BottomColor, _TColor, saturate(localPos.y + _Offset)) * 1.1; // multiply color by gradient lerp

    }
    ENDCG

    }

        Fallback "Diffuse"
}
Шейдер "Toon / Lit Specular Alpha" { Характеристики{ _Color("Основной цвет", Color) = (1,1,1,1) _SColor("Specular Color", Цвет) = (1,1,1,1) _MainTex("Base (RGB)", 2D) = "белый" {} _Ramp("Toon Ramp (RGB)", 2D) = "серый" {} _RampS("Specular Ramp (RGB)", 2D) = "gray" {} // градиент отражения, точка отсечки _SpecSize ("Specular Size", Range (0.65,0.999)) = 0.9 // размер зеркала _SpecOffset ("Specular Offset", Range (0.5,1)) = 0.5 // зеркальное смещение спецификации Ramp _TColor ("Цвет верха наложения градиента", Color) = (1,1,1,1) _BottomColor ("Цвет нижнего слоя наложения градиента", Color) = (0,23,0,0.95,1) _Offset ("Смещение градиента", диапазон (-4,4)) = 3,2 [Toggle (RIM)] _RIM («Обод Френеля?», Float) = 0 _RimColor ("Цвет обода Френеля", Color) = (0,49,0,94,0,64,1) [Toggle (FADE)] _FADE ("Уменьшить блики к низу?", Float) = 0 _TopBottomOffset ("Смещение зеркального затемнения", диапазон (-4,4)) = 3,2 } SubShader { Теги {"Queue" = "Transparent"} LOD 200 Смесь SrcAlpha OneMinusSrcAlpha CGPROGRAM #pragma surface surf ToonRamp vertex: vert keepalpha #pragma shader_feature FADE // переключатель затухания #pragma shader_feature RIM // переключатель Френеля обода sampler2D _Ramp; // настраиваемая функция освещения, использующая нарастание текстуры на основе // по углу между направлением света и нормалью #pragma lighting ToonRamp exclude_path: предварительный проход inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, половина аттенюатора) { #ifndef USING_DIRECTIONAL_LIGHT lightDir = нормализовать (lightDir); #endif половина d = точка (s.Normal, lightDir) * 0,5 + 0,5; half3 ramp = tex2D (_Ramp, float2 (d, d)). rgb; половина4 c; c.rgb = s.Albedo * _LightColor0.rgb * ramp * (att * 2); c.a = s.Alpha; return c; } sampler2D _MainTex; float4 _Color; float4 _SColor; // зеркальный цвет sampler2D _RampS; // зеркальная рампа float _SpecSize; // размер зеркала float _SpecOffset; // смещение зеркального наклона float4 _TColor; // цвет верхнего градиента float4 _BottomColor; // цвет нижнего градиента float _TopBottomOffset; // смещение нижнего градиента float _Offset; // смещение зеркального затухания float4 _RimColor; // цвет обода Френеля struct Input { float2 uv_MainTex: TEXCOORD0; float3 lightDir; float3 worldPos; // положение в мире float3 viewDir; // направление взгляда с камеры }; void vert (inout appdata_full v, out Input o) { UNITY_INITIALIZE_OUTPUT (ввод, o); o.lightDir = WorldSpaceLightDir (v.vertex); // получаем направление освещения в мировом пространстве } void surf (Вход IN, inout SurfaceOutput o) { float3 localPos = (IN.worldPos - mul (unity_ObjectToWorld, float4 (0, 0, 0, 1)). xyz); // локальная позиция объекта со смещением half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color; половина d = точка (o.Normal, IN.lightDir) * 0,5 + _SpecOffset; // исходя из нормального и светового направления half3 rampS = tex2D (_RampS, float2 (d, d)). rgb; // зеркальная рампа float rim = 1 - насыщать (точка (IN.viewDir, o.Normal)); // вычисляем обод Френеля #if RIM o.Emission = _RimColor.rgb * pow (обод, 1.5); // ободок Френеля #endif float specular = (step (_SpecSize, rampS.r)) * rampS * d * _SColor; o.Albedo = зеркальное отражение; // зеркальный o.Alpha = c.a + specular; #if FADE float specular2 = (шаг (_SpecSize, rampS.r)) * rampS * d * saturate (localPos.y + _TopBottomOffset) * _SColor; o.Albedo = specular2; // уменьшение зеркального отражения к низу o.Alpha = c.a + specular2; #endif o.Albedo + = c.rgb * lerp (_BottomColor, _TColor, saturate (localPos.y + _Offset)) * 1.1; // умножаем цвет на градиент lerp } ENDCG } Резервный вариант "Diffuse" }
translated from : English