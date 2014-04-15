#pragma once

#include <stdint.h>
#include <string>
#include <map>
#include <vector>
#include "Buffer.h"

#define VVT_NULL			0
#define VVT_BOOLEAN		1
#define VVT_INT			2
#define VVT_INT8			3
#define VVT_INT16		4
#define VVT_INT32		5
#define VVT_INT64		6
#define VVT_UINT			7
#define VVT_UINT8		8
#define VVT_UINT16		9
#define VVT_UINT32		10
#define VVT_UINT64		11
#define VVT_FLOAT32		13
#define VVT_FLOAT64		14
// #define VVT_LEN_BYTES	17
#define VVT_MAP			21
#define VVT_LIST			23
#define VVT_LEN_STRING	24
#define VVT_STRING		24

class VarValue
{
public:
	bool IsType(int t) {
		return type==t;
	}	
	void Clear();

	static VarValue* vvNull() {
		return new VarValue();
	}
	static VarValue* vvBool(bool v) {
		VarValue* r = new VarValue();
		r->type = VVT_BOOLEAN;
		r->b=v;
		return r;
	}
	static VarValue* vvInt8(int8_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_INT8;
		r->i8 = v;
		return r;
	}
	static VarValue* vvInt16(int16_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_INT16;
		r->i16 = v;
		return r;
	}
	static VarValue* vvInt32(int32_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_INT32;
		r->i32 = v;
		return r;
	}
	static VarValue* vvInt(int v) {
		return vvInt32((int32_t)v);
	}
	static VarValue* vvInt64(int64_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_INT64;
		r->i64 = v;
		return r;
	}
	static VarValue* vvUint8(uint8_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_UINT8;
		r->ui8 = v;
		return r;
	}
	static VarValue* vvUint16(uint16_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_UINT16;
		r->ui16 = v;
		return r;
	}
	static VarValue* vvUint32(uint32_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_UINT32;
		r->ui32 = v;
		return r;
	}
	static VarValue* vvUint64(uint64_t v) {
		VarValue* r = new VarValue();
		r->type = VVT_UINT64;
		r->ui64 = v;
		return r;
	}
	static VarValue* vvFloat32(float v) {
		VarValue* r = new VarValue();
		r->type = VVT_FLOAT32;
		r->f32 = v;
		return r;
	}
	static VarValue* vvFloat64(double v) {
		VarValue* r = new VarValue();
		r->type = VVT_FLOAT64;
		r->f64 = v;
		return r;
	}
	static VarValue* vvString(std::string v) {
		VarValue* r = new VarValue();
		r->type = VVT_LEN_STRING;
		r->s = v;
		return r;
	}
	static VarValue* vvList() {
		VarValue* r = new VarValue();
		r->type = VVT_LIST;
		return r;
	}
	static VarValue* vvMap() {
		VarValue* r = new VarValue();
		r->type = VVT_MAP;
		return r;
	}

public:
	VarValue();
	~VarValue();

public:
	int type;
	union {
		bool b;
		uint8_t ui8;
		int8_t	i8;
		uint16_t ui16;
		int16_t	i16;
		uint32_t ui32;
		int32_t	i32;
		uint64_t ui64;
		int64_t	i64;
		float f32;
		double f64;
	};
	std::vector<VarValue*> l;
	std::map<std::string, VarValue*> m;
	std::string s;
};

class Coder
{
public:
	static bool readBool(Buffer* buf, int* err);
	static int writeBool(Buffer* buf, bool v);

	static int8_t readFixInt8(Buffer *buf, int* err);
	static int writeFixInt8(Buffer *buf, int8_t v);

	static int16_t readFixInt16(Buffer *buf, int* err);
	static int writeFixInt16(Buffer *buf, int16_t v);

	static int32_t readFixInt32(Buffer *buf, int* err);
	static int writeFixInt32(Buffer *buf, int32_t v);

	static int64_t readFixInt64(Buffer *buf, int* err);
	static int writeFixInt64(Buffer *buf, int64_t v);

	static uint8_t readFixUint8(Buffer *buf, int* err) {
		return (uint8_t) readFixInt8(buf, err);
	}
	static int writeFixUint8(Buffer *buf, uint8_t v) {
		return writeFixInt8(buf, (int8_t) v);
	}

	static uint16_t readFixUint16(Buffer *buf, int* err) {
		return (uint16_t) readFixInt16(buf, err);
	}
	static int writeFixUint16(Buffer *buf, uint16_t v) {
		return writeFixInt16(buf, (int16_t) v);
	}
	static uint32_t readFixUint32(Buffer *buf, int* err) {
		return (uint32_t) readFixInt32(buf, err);
	}
	static int writeFixUint32(Buffer *buf, uint32_t v) {
		return writeFixInt32(buf, (int32_t) v);
	}
	static uint64_t readFixUint64(Buffer *buf, int* err) {
		return (uint64_t) readFixInt64(buf, err);
	}
	static int writeFixUint64(Buffer *buf, uint64_t v) {
		return writeFixInt64(buf, (int64_t) v);
	}

	static float readFloat32(Buffer* buf, int* err);
	static int writeFloat32(Buffer* buf, float v);

	static double readFloat64(Buffer* buf, int* err);
	static int writeFloat64(Buffer* buf, double v);

	static uint16_t readUint16(Buffer *buf, int* err);
	static int writeUint16(Buffer *buf, uint16_t v);

	static uint32_t readUint32(Buffer *buf, int* err);
	static int writeUint32(Buffer *buf, uint32_t v);

	static uint64_t readUint64(Buffer *buf, int* err);
	static int writeUint64(Buffer *buf, uint64_t v);

	static int16_t readInt16(Buffer *buf, int* err);
	static int writeInt16(Buffer *buf, int16_t v);

	static int32_t readInt32(Buffer *buf, int* err);
	static int writeInt32(Buffer *buf, int32_t v);

	static int64_t readInt64(Buffer *buf, int* err);
	static int writeInt64(Buffer *buf, int64_t v);

	static std::string readString(Buffer *buf, int* err);	
	static int writeString(Buffer* buf, std::string v);

	static std::string readLenString(Buffer *buf, int* err);
	static int writeLenString(Buffer* buf, std::string v);

	static VarValue* readVar(Buffer *buf, int* err);
	static int writeVar(Buffer* buf, VarValue* v);
};

