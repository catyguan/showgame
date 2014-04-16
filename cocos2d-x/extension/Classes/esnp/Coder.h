#ifndef  __ESNP_CODER_H__
#define  __ESNP_CODER_H__

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

class ESNPVarValue
{
public:
	bool IsType(int t) {
		return type==t;
	}	
	void Clear();

	static ESNPVarValue* vvNull() {
		return new ESNPVarValue();
	}
	static ESNPVarValue* vvBool(bool v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_BOOLEAN;
		r->b=v;
		return r;
	}
	static ESNPVarValue* vvInt8(int8_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_INT8;
		r->i8 = v;
		return r;
	}
	static ESNPVarValue* vvInt16(int16_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_INT16;
		r->i16 = v;
		return r;
	}
	static ESNPVarValue* vvInt32(int32_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_INT32;
		r->i32 = v;
		return r;
	}
	static ESNPVarValue* vvInt(int v) {
		return vvInt32((int32_t)v);
	}
	static ESNPVarValue* vvInt64(int64_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_INT64;
		r->i64 = v;
		return r;
	}
	static ESNPVarValue* vvUint8(uint8_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_UINT8;
		r->ui8 = v;
		return r;
	}
	static ESNPVarValue* vvUint16(uint16_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_UINT16;
		r->ui16 = v;
		return r;
	}
	static ESNPVarValue* vvUint32(uint32_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_UINT32;
		r->ui32 = v;
		return r;
	}
	static ESNPVarValue* vvUint64(uint64_t v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_UINT64;
		r->ui64 = v;
		return r;
	}
	static ESNPVarValue* vvFloat32(float v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_FLOAT32;
		r->f32 = v;
		return r;
	}
	static ESNPVarValue* vvFloat64(double v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_FLOAT64;
		r->f64 = v;
		return r;
	}
	static ESNPVarValue* vvString(std::string v) {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_LEN_STRING;
		r->s = v;
		return r;
	}
	static ESNPVarValue* vvList() {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_LIST;
		return r;
	}
	static ESNPVarValue* vvMap() {
		ESNPVarValue* r = new ESNPVarValue();
		r->type = VVT_MAP;
		return r;
	}

public:
	ESNPVarValue();
	~ESNPVarValue();

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
	std::vector<ESNPVarValue*> l;
	std::map<std::string, ESNPVarValue*> m;
	std::string s;
};

class ESNPCoder
{
public:
	static bool readBool(ESNPBuffer* buf, int* err);
	static int writeBool(ESNPBuffer* buf, bool v);

	static int8_t readFixInt8(ESNPBuffer *buf, int* err);
	static int writeFixInt8(ESNPBuffer *buf, int8_t v);

	static int16_t readFixInt16(ESNPBuffer *buf, int* err);
	static int writeFixInt16(ESNPBuffer *buf, int16_t v);

	static int32_t readFixInt32(ESNPBuffer *buf, int* err);
	static int writeFixInt32(ESNPBuffer *buf, int32_t v);

	static int64_t readFixInt64(ESNPBuffer *buf, int* err);
	static int writeFixInt64(ESNPBuffer *buf, int64_t v);

	static uint8_t readFixUint8(ESNPBuffer *buf, int* err) {
		return (uint8_t) readFixInt8(buf, err);
	}
	static int writeFixUint8(ESNPBuffer *buf, uint8_t v) {
		return writeFixInt8(buf, (int8_t) v);
	}

	static uint16_t readFixUint16(ESNPBuffer *buf, int* err) {
		return (uint16_t) readFixInt16(buf, err);
	}
	static int writeFixUint16(ESNPBuffer *buf, uint16_t v) {
		return writeFixInt16(buf, (int16_t) v);
	}
	static uint32_t readFixUint32(ESNPBuffer *buf, int* err) {
		return (uint32_t) readFixInt32(buf, err);
	}
	static int writeFixUint32(ESNPBuffer *buf, uint32_t v) {
		return writeFixInt32(buf, (int32_t) v);
	}
	static uint64_t readFixUint64(ESNPBuffer *buf, int* err) {
		return (uint64_t) readFixInt64(buf, err);
	}
	static int writeFixUint64(ESNPBuffer *buf, uint64_t v) {
		return writeFixInt64(buf, (int64_t) v);
	}

	static float readFloat32(ESNPBuffer* buf, int* err);
	static int writeFloat32(ESNPBuffer* buf, float v);

	static double readFloat64(ESNPBuffer* buf, int* err);
	static int writeFloat64(ESNPBuffer* buf, double v);

	static uint16_t readUint16(ESNPBuffer *buf, int* err);
	static int writeUint16(ESNPBuffer *buf, uint16_t v);

	static uint32_t readUint32(ESNPBuffer *buf, int* err);
	static int writeUint32(ESNPBuffer *buf, uint32_t v);

	static uint64_t readUint64(ESNPBuffer *buf, int* err);
	static int writeUint64(ESNPBuffer *buf, uint64_t v);

	static int16_t readInt16(ESNPBuffer *buf, int* err);
	static int writeInt16(ESNPBuffer *buf, int16_t v);

	static int32_t readInt32(ESNPBuffer *buf, int* err);
	static int writeInt32(ESNPBuffer *buf, int32_t v);

	static int64_t readInt64(ESNPBuffer *buf, int* err);
	static int writeInt64(ESNPBuffer *buf, int64_t v);

	static std::string readString(ESNPBuffer *buf, int* err);	
	static int writeString(ESNPBuffer* buf, std::string v);

	static std::string readLenString(ESNPBuffer *buf, int* err);
	static int writeLenString(ESNPBuffer* buf, std::string v);

	static ESNPVarValue* readVar(ESNPBuffer *buf, int* err);
	static int writeVar(ESNPBuffer* buf, ESNPVarValue* v);

	static void header(char* buf, int mt, int sz);
};

#define MT_END					0x00
#define MT_MESSAGE_ID			0x11
#define MT_SOURCE_MESSAGE_ID	0x12
#define MT_HEADER				0x14
#define MT_DATA					0x15
#define MT_PAYLOAD				0x16
#define MT_ADDRESS				0x17
#define MT_ERROR				0x1D
#define MT_FLAG					0x1E

#define ADDRESS_SERVICE			30
#define ADDRESS_OP				20

#define FLAG_TRACE		1
#define FLAG_RESP		3
#define FLAG_REQUEST 	4
#define FLAG_INFO		5
#define FLAG_EVENT 		6

#endif